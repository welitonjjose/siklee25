require 'cpf_cnpj'

class Atestado < ApplicationRecord
  CRM_FORMAT = /(?<crm>^\d{1,7})(-?(?<state>[A-Z]{2})$)?/
  STRICT_CRM_REGISTRY_FORMAT = /\A(NÃO INFORMADO|\d{1,7}-[A-Z]{2})\z/

  HOURS_IN_A_DAY = 24
  SECONDS_IN_A_HOUR = 3_600
  SECONDS_IN_A_DAY = HOURS_IN_A_DAY * SECONDS_IN_A_HOUR

  MEDICAL_CERTIFICATE_TYPES = {
    default: 'Atestado Medico',
    presence: 'Declaração de Comparecimento',
    accompany: 'Atestado de Acompanhante',
    aso: 'Atestado de Saude Ocupacional (ASO)'
  }

  ABSENCE_REASONS_FOR_DEFAULT = {
    sickness: 'Doença',
    work_accident: 'Acidente de Trabalho',
    traffic_accident: 'Acidente de Trânsito',
    maternity_leave: 'Licença Maternidade'
  }

  REGISTRY_TYPES = {
    crm: 'CRM-medico',
    cro: 'CRO-dentista'
  }.freeze

  COMMON_ORIGINS = %w[empresa funcionario gestor]

  PG_SEARCH_PREFIX = /pg_search_\w+.rank/

  belongs_to :funcionario, optional: true
  belongs_to :empresa
  belongs_to :consultant, optional: true
  belongs_to :consultant_team, optional: true

  has_many_attached :photos
  has_one_attached :cfm_photo

  has_enumeration_for :physician_status_on_cfm,
                      with: CfmPhysicianStatuses, create_scopes: { prefix: true }

  has_enumeration_for :examining_physician_status_on_cfm,
                      with: CfmPhysicianStatuses, create_scopes: { prefix: true }

  include PgSearch::Model

  pg_search_scope :global_search,
                  against: %i[nome_do_medico tipo_de_registro numero_de_registro especialidade_medica cnpj instituicao_de_saude
                              tipo_de_atestado cid descricao_do_afastamento cidade exames exames_complementares],
                  associated_against: {
                    funcionario: %i[nome cpf rg registro_empresa pis]
                  },
                  using: {
                    tsearch: { prefix: true }
                  }

  pg_search_scope :global_search_gestor,
                  against: %i[nome_do_medico tipo_de_registro numero_de_registro especialidade_medica cnpj instituicao_de_saude
                              tipo_de_atestado cid descricao_do_afastamento cidade exames exames_complementares],
                  using: {
                    tsearch: { prefix: true }
                  }

  # multisearchable against: [:vinculo]

  validates :photos, attached: true, if: :common_origin?,
                     length: { maximum: 1 }

  validates :numero_de_registro, presence: true,
                                 format: STRICT_CRM_REGISTRY_FORMAT,
                                 length: { minimum: 4, maximum: 13 }, if: :common_origin?

  validates :tipo_de_atestado, presence: true, if: :common_origin?

  validates :descricao_do_afastamento, presence: true, if: :atestado_medico?

  validates :examinador_registro, presence: true, if: :aso?

  validates :examinador_numero_registro, presence: true,
                                         format: STRICT_CRM_REGISTRY_FORMAT,
                                         length: { minimum: 4, maximum: 13 }, if: :aso?

  validates :exames, presence: true, if: :aso?
  validates :exames_complementares, presence: true, if: :aso?

  validates :cid, presence: true, if: :common_origin?
  validates :nome_funcionario, presence: true

  validates :funcionario_okay, acceptance: true, if: proc { |a| a.origem == 'funcionario' || a.origem == 'gestor' }
  validates :empresa_okay, acceptance: true, if: proc { |a| a.origem == 'empresa' }

  validate :dia_tempo_dispensa_maior_que_zero, unless: :aso?
  validate :tempo_dispensa_presence
  validate :dados_instituicao
  validate :status_geral

  before_save :tempo_dispensa_nao_aplicavel, :carregar_dados_instituicao

  scope :company_approved, -> { where(empresa_okay: true) }

  def self.highest_issuer_in_percentage(scope, total_to_compare)
    return 0 if scope.count.zero?

    issues = scope.group(:empresa_id, :tipo_de_registro, :numero_de_registro).count

    max_issues = issues.max_by { |_, count| count }

    percentage = (max_issues[1] * 100) / total_to_compare

    percentage.to_i
  end

  def self.receiving_average_in_days(relation)
    return 0 if relation.empty?

    search_sql = relation.to_sql

    pg_search_matches = search_sql.scan(PG_SEARCH_PREFIX)
    pg_search_columns = pg_search_matches.uniq

    group_by_clause = %w[id data_de_emissao].map { |column| "atestados.#{column}" }
    group_by_clause << pg_search_columns

    average = relation.reorder('').pluck(
      Arel.sql("COALESCE(
          AVG(
            EXTRACT(
              EPOCH FROM AGE(data_de_apresentacao, data_de_emissao)
            )
          ) / #{SECONDS_IN_A_DAY}
        )")
    ).first

    average ? average.ceil : 0
  end

  def self.absence_duration_in_days(relation)
    durations = relation.map(&:tempo_de_dispensa_em_horas)

    if durations.any?
      hours = durations.map(&:to_f).sum.round.to_i
      days = (hours / HOURS_IN_A_DAY).round.to_i

      days.zero? ? 1 : days
    else
      0
    end
  end

  def tempo_dispensa_em_dias
    duration = tempo_de_dispensa_em_horas

    return 0 if duration.nil?

    days = (duration.to_i / HOURS_IN_A_DAY).round.to_i

    days.zero? ? 1 : days
  end

  def self.absence_duration_average_in_days(relation)
    durations = relation.map(&:tempo_de_dispensa_em_horas)

    if durations.any?
      total_hours = (durations.map(&:to_f).sum / durations.size).round.to_i

      total_hours < 24 ? 1 : (total_hours / HOURS_IN_A_DAY).round.to_i
    else
      0
    end
  end

  def self.receiving_range_peaks
    return nil if count.zero?

    interval_data = pluck(
      Arel.sql("MIN(
        EXTRACT(EPOCH FROM AGE(data_de_apresentacao, data_de_emissao)) / #{SECONDS_IN_A_DAY}
        ) as min_difference"),
      Arel.sql("MAX(
        EXTRACT(EPOCH FROM AGE(data_de_apresentacao, data_de_emissao)) / #{SECONDS_IN_A_DAY}
        ) as max_difference")
    ).first

    min_difference = interval_data[0]
    max_difference = interval_data[1]

    "#{min_difference.to_i}-#{max_difference.to_i}"
  end

  def self.absence_duration_range_peaks(relation, format: :days)
    return nil if relation.count.zero?

    durations = relation.map(&:tempo_de_dispensa_em_horas).map(&:to_f)

    min_duration = durations.min.to_i
    max_duration = durations.max.to_i

    if format == :days
      min_duration = min_duration / HOURS_IN_A_DAY
      max_duration = max_duration / HOURS_IN_A_DAY
    end

    "#{min_duration}-#{max_duration}"
  end

  def common_origin?
    COMMON_ORIGINS.include? origem
  end

  def crm_registered?
    tipo_de_registro == REGISTRY_TYPES[:crm]
  end

  def cro_registered?
    tipo_de_registro == REGISTRY_TYPES[:cro]
  end

  def aso?
    tipo_de_atestado == MEDICAL_CERTIFICATE_TYPES[:aso]
  end

  def atestado_medico?
    tipo_de_atestado == 'Atestado Medico'
  end

  def self.crm_number(doctor_registry)
    CRM_FORMAT.match(doctor_registry)&.named_captures&.dig('crm')
  end

  def self.crm_region(doctor_registry)
    CRM_FORMAT.match(doctor_registry)&.named_captures&.dig('state')
  end

  def tempo_dispensa_nao_aplicavel
    self.tempo_de_dispensa = 'Não aplicável' if tempo_de_dispensa.blank?
  end

  def dados_instituicao
    errors.add :cnpj, 'ou a Instituição de Saúde precisa ser definido' if cnpj.blank? && instituicao_de_saude.blank?
    return unless cnpj&.empty? && instituicao_de_saude&.empty?
    errors.add :cnpj, 'ou a Instituição de Saúde precisa ser definido'
  end

  def dia_tempo_dispensa_maior_que_zero
    timer = (dia_tempo_de_dispensa * 24) + dia_tempo_de_dispensa_in_hours
    return unless timer >= 24 && tipo_de_atestado != 'Atestado Medico'


    errors.add :tipo_de_atestado, 'deve ser "Atestado Medico", caso a ausência seja maior ou igual a 1 (um) dia'
  end

  def dia_tempo_de_dispensa
    return tempo_de_dispensa.split(' dia').first.to_i if tempo_de_dispensa&.include?('dia')
    0
  end

  def dia_tempo_de_dispensa_in_hours
    return tempo_de_dispensa.split(' horas').first.to_i if tempo_de_dispensa&.include?('horas')
    0
  end

  def tempo_dispensa_presence
    return if aso? || tempo_de_dispensa.present?

    errors.add :tempo_de_dispensa, 'precisa ser definido'
  end

  def carregar_dados_instituicao
    return if cnpj.blank? || !changes.include?(:cnpj)

    dados = CnpjService.consultar(cnpj.gsub(/\D/, ''))

    return unless dados['status'] = 'OK'

    self.instituicao_de_saude = dados['nome']
    self.endereco = dados['logradouro']
    self.endereco += ', ' + dados['numero'] unless dados['numero'].nil?
    self.endereco += ', ' + dados['complemento'] unless dados['complemento'].nil?
    self.cidade = dados['municipio']
    self.estado = dados['uf']
    self.cep = dados['cep']
    self.telefone = dados['telefone']
  end

  def tempo_de_dispensa_em_horas
    tempo = tempo_de_dispensa.downcase

    dias = tempo.match(/(\d+) dias?/)&.captures&.first&.to_i || 0
    horas = tempo.match(/(\d+) horas?/)&.captures&.first&.to_i || 0
    minutos = tempo.match(/(\d+) minutos?/)&.captures&.first&.to_i || 0

    total_horas = (dias * 24) + horas + (minutos.to_f / 60)

    format("%.2f", total_horas)
  end

  def source_from_company_or_employer?
    origem == 'empresa'
  end

  class << self
    alias cro_number crm_number
    alias cro_region crm_region
  end

  def status_geral
    if empresa_subscrever && empresa_okay
      errors.add(:empresa_subscrever, 'Não é possível subsescrever um atestado já aprovado pela empresa ou aprovar um atestado subscrito.')
    end
  end

  before_validation :uppercase_numero_de_registro
  before_validation :uppercase_examinador_numero_registro

  def uppercase_numero_de_registro
    numero_de_registro.upcase! unless numero_de_registro.nil?
  end

  def uppercase_examinador_numero_registro
    examinador_numero_registro.upcase! unless examinador_numero_registro.nil?
  end

end
