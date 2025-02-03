require 'cpf_cnpj'
require 'open-uri'
require 'csv'

class Funcionario < ApplicationRecord
  devise :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable,
         :password_expirable,
         omniauth_providers: [:facebook]

  devise :two_factor_authenticatable, :two_factor_backupable,
         otp_backup_code_length: 10, otp_number_of_backup_codes: 10,
         :otp_secret_encryption_key => 'cb067d90-b298-4f22-b5e4-d203e2e3bb71'


  has_one :lgpd

  has_many :refatestados, class_name: "Atestado", foreign_key: :funcionario_id
  has_many :atestados, lambda { |employee|
    if employee.employer?
      unscope(:where).where(
        empresa_id: Funcionario.employer_company_ids(employee)
      )
    else
      where(funcionario_id: employee.id)
    end
  }

  has_many :cfms
  has_many :okays
  has_one_attached :photo
  has_many :vinculos, dependent: :destroy
  has_many :empresas, through: :vinculos
  has_many :squads, through: :vinculos

  accepts_nested_attributes_for :vinculos, allow_destroy: true
  validates_associated :vinculos

  include PgSearch::Model

  scope :ativos, -> { where(deleted_at: nil) }
  scope :inativos, -> { where.not(deleted_at: nil) }

  validates :nome, :cpf, :rg, :sexo, :data_nascimento, :celular, presence: true
  validates :cpf, :rg, :email, uniqueness: true
  validates :sexo, inclusion: { in: ['Feminino', 'Masculino', 'Prefiro Não Informar'] }

  pg_search_scope :global_search,
                  against: %i[nome cpf rg registro_empresa pis],
                  associated_against: {
                    vinculo: %i[funcionario_id cargo]
                  },
                  using: {
                    tsearch: { prefix: true }
                  }

  def self.from_omniauth(auth)
    funcionario_params = auth.slice(:provider, :uid)
    funcionario_params.merge! auth.info.slice(:email, :nome)
    # funcionario_params[:facebook_picture_url] = auth.info.image
    # funcionario_params[:token] = auth.credentials.token
    # funcionario_params[:token_expiry] = Time.at(auth.credentials.expires_at)
    funcionario_params = funcionario_params.to_h

    funcionario = Funcionario.find_by(provider: auth.provider, uid: auth.uid)
    funcionario ||= Funcionario.find_by(email: auth.info.email) # Funcionario já se logou usando esse email
    if funcionario
      funcionario.update(funcionario_params)
    else
      funcionario = Funcionario.new(funcionario_params)
      funcionario.facebook_photo_url = auth.info.image
      funcionario.password = Devise.friendly_token[0, 20] # Senha Fake para validação
      funcionario.save
    end

    funcionario
  end

  def self.import(empresa_id)
    # ImportarFuncionariosJob.perform_later(tmp_file, empresa_id)

    xlsx = Roo::Spreadsheet.open("#{Rails.root}/tmp/funcionarios.xlsx")
    sheet = xlsx.sheet(0)

    max_rows = sheet.last_row
    current_row = 2

    until current_row > max_rows
      begin
        funcionario = Funcionario.new({
                                        nome: sheet.cell(current_row, 1),
                                        cpf: sheet.cell(current_row, 2),
                                        rg: sheet.cell(current_row, 3),
                                        data_nascimento: sheet.cell(current_row, 4).strftime('%d/%m/%Y'),
                                        sexo: sheet.cell(current_row, 5),
                                        celular: sheet.cell(current_row, 6),
                                        email: sheet.cell(current_row, 7),
                                        registro_empresa: sheet.cell(current_row, 11),
                                        pis: sheet.cell(current_row, 12),
                                        risco_ocupacional: sheet.cell(current_row, 13),
                                      })

        funcionario.save

        vinculo = Vinculo.new({
                                empresa_id: empresa_id,
                                funcionario_id: funcionario.id,
                                empregador: false,
                                cargo: sheet.cell(current_row, 8),
                                squad: sheet.cell(current_row, 9),
                                aprovado: false,
                                cnpj_employee: sheet.cell(current_row, 10),
                              })

        vinculo.save
      rescue StandardError
      end

      current_row += 1
    end
  end

  def self.employer_company_ids(employee)
    employee.vinculos.where(
      'vinculos.empregador = :employer AND
      vinculos.funcionario_id = :employee_id',
      employer: true,
      employee_id: employee.id
    ).pluck(:empresa_id).uniq
  end

  def from_facebook?
    provider.present? && uid.present?
  end

  def most_recent_bond
    vinculos.where(ativo: true).last
  end

  def manager?
    vinculos.exists?(gestor: true)
  end

  def employer?
    vinculos.exists?(empregador: true)
  end

  def gerar_vinculo
    empregador = Empresa.find_by(razao_social: empresa)
    Vinculo.create(empresa: empregador, funcionario: self)
  end

  def destroy(mode = :soft)
    if mode == :hard
      super()
    else
      update_attribute(:deleted_at, Time.zone.now)
    end
  end

  # multisearchable against: [:nome, :cpf, :rg ]

  # This generates a random password reset token for the user
  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while Funcionario.exists?(column => self[column])
  end

  def empresa
    most_recent_bond.empresa
  end

  def authorized_company_ids
    most_recent_bond.empresa.id
  end

  def generate_two_factor_secret_if_missing!
    return unless otp_secret.nil?
    update!(otp_secret: Funcionario.generate_otp_secret)
  end

  # Ensure that the user is prompted for their OTP when they login
  def enable_two_factor!
    update!(otp_required_for_login: true)
  end

  # Disable the use of OTP-based two-factor.
  def disable_two_factor!
    update!(
      otp_required_for_login: false,
      otp_secret: nil,
      otp_backup_codes: nil)
  end

  # URI for OTP two-factor QR code
  def two_factor_qr_code_uri
    issuer = "Siklee:"
    label = [issuer, email].join(':')

    otp_provisioning_uri(label, issuer: issuer)
  end

  # Determine if backup codes have been generated
  def two_factor_backup_codes_generated?
    otp_backup_codes.present?
  end

  def opt?
    return true if otp_required_for_login
    return true if valid_opt_at.present? && valid_opt_at > Time.current

    false
  end
end
