class Vinculo < ApplicationRecord
  belongs_to :empresa
  belongs_to :funcionario
  belongs_to :squad
  has_many :refatestados, through: :funcionario


  belongs_to :lider, class_name: "Funcionario", optional: true, foreign_key: "funcionario_lider_id"

  include PgSearch::Model

  validates_presence_of :empresa, :funcionario, :cargo, :squad

  validate :somente_um_vinculo_ativo, on: :create
  validate :somente_um_vinculo_ativo_update, on: :update


  validate :lider_cannot_be_funcionario

  def lider_cannot_be_funcionario
    return if funcionario_lider_id.nil?

    if funcionario_lider_id == funcionario_id
      errors.add(:funcionario_lider_id, "Funcionário não pode ser lider dele mesmo")
    end
  end


  pg_search_scope :global_search,
                  against: %i[funcionario_id cargo],
                  associated_against: {
                    funcionario: %i[nome cpf rg registro_empresa pis]
                  },
                  using: {
                    tsearch: { prefix: true }
                  }

  def subordinados
    Vinculo.where(funcionario_lider_id: self.id)
  end

  def nome_lider
    return 'Admin-empresa' if lider.nil?

    lider.nome
  end

  def sum_tempo_de_dispensa_em_horas_per_funcionario
    hours = 0
    self.refatestados.each do |atestado|
      hours += atestado.tempo_de_dispensa_em_horas.to_f
    end
    hours
  end

  def sum_tempo_de_dispensa_em_horas_per_funcionario?
    return false unless sum_tempo_de_dispensa_em_horas_per_funcionario > 48

    return true
  end

  def somente_um_vinculo_ativo
    if Vinculo.where(funcionario_id: funcionario_id)
              .where(ativo: true)
              .count.positive?
      errors.add(:ativo, "funcionário já possui vinculo ativo com outra empresa.")
    end
  end

  def somente_um_vinculo_ativo_update
    vinculo_ativo = Vinculo.where(funcionario_id: funcionario_id).where(ativo: true).first
    if self.ativo && !vinculo_ativo.nil? && vinculo_ativo.id != self.id
      errors.add(:ativo, "funcionário já possui vinculo ativo com outra empresa.")
    end
  end

end
