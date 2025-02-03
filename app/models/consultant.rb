class Consultant < ApplicationRecord

  devise :two_factor_authenticatable, :two_factor_backupable,
         otp_backup_code_length: 10, otp_number_of_backup_codes: 10,
         :otp_secret_encryption_key => '20a4ced1-47e7-4d92-8be3-4379e3844faa'

  devise :registerable,
         :recoverable, :rememberable, :validatable, :password_expirable

  has_many :links, dependent: :restrict_with_error

  has_many :empresas, -> { distinct }, through: :links, dependent: :restrict_with_error
  has_many :atestados, through: :empresas

  has_many :collaborations
  has_many :collaborators, through: :collaborations, dependent: :restrict_with_error, class_name: 'ConsultantTeam'

  has_one_attached :logo
  has_one_attached :photo

  validates :razao_social, :cnpj, :nome, :celular, :endereco, :estado, :cidade, :cep, presence: true

  validates :email, :cnpj, uniqueness: true

  def authorized_company_ids
    links.distinct(:empresa_id).pluck(:empresa_id)
  end

  def nome
    razao_social
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
    issuer = "Siklee-Consultor:"
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
