# frozen_string_literal: true

class Empresas::SessionsController < Devise::SessionsController
  def create
    remove_opt if params[:empresa][:otp_attempt].blank?
    super
  end

  private

  def remove_opt
    resource = Empresa.find_by(email: params[:empresa][:email])
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
end