class ConsultantTeam < ApplicationRecord
  include PgSearch::Model

  devise :two_factor_authenticatable, :two_factor_backupable,
         otp_backup_code_length: 10, otp_number_of_backup_codes: 10,
         :otp_secret_encryption_key => '518e00b9-1134-419f-b2f5-40dcc00bc6b7'

  devise :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable,
         :password_expirable, omniauth_providers: [:facebook]

  has_many :collaborations, foreign_key: :collaborator_id

  has_many :approved_collaborations, -> { where(status: :approved) },
    class_name: 'Collaboration', foreign_key: :collaborator_id

  has_many :consultants, through: :collaborations
  has_many :atestados, through: :consultants

  has_many :empresas, -> { distinct }, through: :consultants

  has_one_attached :photo

  validates_presence_of :nome, :celular, :function
  validates :email, uniqueness: true
  # validates :collaborations, length: { is: 1 }, on: :create

  accepts_nested_attributes_for :collaborations, limit: 1

  pg_search_scope :global_search,
    against: %i[nome function],
    using: {
      tsearch: { prefix: true }
    }

  def approved_consultant_ids
    approved_collaborations.pluck(:consultant_id).uniq
  end

  def authorized_company_ids
    Link.where(consultant_id: approved_consultant_ids).distinct(:empresa_id).pluck(:empresa_id)
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
    issuer = "Siklee-Team:"
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
