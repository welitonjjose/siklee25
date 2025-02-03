class Admin < ApplicationRecord

  devise :two_factor_authenticatable, :two_factor_backupable,
         otp_backup_code_length: 10, otp_number_of_backup_codes: 10,
         :otp_secret_encryption_key => '8b7ddcce-d5f2-490c-8925-97352fd26504'
  devise :trackable, :timeoutable, :lockable, :password_expirable
  

  has_many :bi_urls

  # Public: Use to fake the association for admin
  # should be used as ActiveRecord scope.
  def atestados
    Atestado.all
  end

  def authorized_company_ids
    Empresa.distinct(:id).pluck(:id)
  end

  def nome
    'Admin'
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
    issuer = "Siklee-Admin:"
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
