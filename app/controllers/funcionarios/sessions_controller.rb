class Funcionarios::SessionsController < Devise::SessionsController
  before_action :configure_permitted_parameters

  def create
    remove_opt if params[:funcionario][:otp_attempt].blank?
    super
  end

  private

  def remove_opt
    resource = Funcionario.find_by(email: params[:funcionario][:email])
    if resource.present?
      resource.update(
        otp_required_for_login: false,
        encrypted_otp_secret: nil,
        encrypted_otp_secret_iv: nil,
        encrypted_otp_secret_salt: nil,
        otp_backup_codes: nil,
        consumed_timestep: nil
      )
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
  end
end
