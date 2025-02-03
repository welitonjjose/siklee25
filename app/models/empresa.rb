require "cpf_cnpj"

class Empresa < ApplicationRecord

  # acts_as_token_authenticatable

  devise :two_factor_authenticatable, :two_factor_backupable,
         otp_backup_code_length: 10, otp_number_of_backup_codes: 10,
         :otp_secret_encryption_key => 'f145403a-5878-42ea-972f-f31523c4de6f'

  devise :registerable,
         :recoverable, :rememberable, :validatable,
         :password_expirable

  has_one_attached :logo

  has_one_attached :photo
  has_many :vinculos, dependent: :destroy
  has_many :funcionarios, through: :vinculos
  has_many :atestados
  has_many :okays

  has_many :links

  has_many :consultants, through: :links, dependent: :restrict_with_error
  has_many :collaborators, through: :consultants, dependent: :restrict_with_error, class_name: 'ConsultantTeam'

  before_validation :before_validation_set_token!, on: :create

  validates :razao_social, :cnpj, :telefone, :celular,
    :endereco, :estado, :cidade, :cep, presence: true
  validates :email, :token, uniqueness: true

  alias_attribute :authentication_token, :token

  after_create :send_welcome_email
  before_create :set_password_changed_at

  def any_approved_consultant?
    links.any?
  end

  def approved_consultants
    consultant_ids = links.pluck(:consultant_id).uniq

    consultants.distinct(:consultant_id).where(id: consultant_ids)
  end

  def empresa
    self
  end

  def authorized_company_ids
    [self.id]
  end

  def nome
    razao_social
  end

  def send_welcome_email
    AccountMailer.welcome(
      self,
      role: :company,
      generated_password: nil
    ).deliver_now
  end

  def opt?
    return true if otp_required_for_login
    return true if valid_opt_at.present? && valid_opt_at > Time.current

    false
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
    issuer = "Siklee-Empresa:"
    label = [issuer, email].join(':')

    otp_provisioning_uri(label, issuer: issuer)
  end

  # Determine if backup codes have been generated
  def two_factor_backup_codes_generated?
    otp_backup_codes.present?
  end

  private

  def before_validation_set_token!
    self.token = SecureRandom.base58(128)
  end

  def set_password_changed_at
    self.password_changed_at = Time.now
  end
end
