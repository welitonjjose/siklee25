class TwoFactorSettingsController < ApplicationController
  # layout 'redesign'
  def new
    if current_user.otp_required_for_login
      flash[:alert] = 'A seguranca de 2 fatores está habilitada.'
      return redirect_to set_registration_path
    end

    current_user.generate_two_factor_secret_if_missing!
  end

  def create
    unless current_user.valid_password?(enable_2fa_params[:password])
      flash.now[:alert] = 'Senha Incorreta'
      return render :new
    end

    if current_user.validate_and_consume_otp!(enable_2fa_params[:code])
      current_user.enable_two_factor!

      flash[:notice] = 'Autenticação de dois fatores habilitada com sucesso. Anote seus códigos de backup.'
      redirect_to edit_two_factor_settings_path
    else
      flash.now[:alert] = 'Código de verificação inválido. Tente novamente.'
      render :new
    end
  end

  def edit
    unless current_user.otp_required_for_login
      flash[:alert] = 'Ative a autenticação de dois fatores primeiro.'
      return redirect_to new_two_factor_settings_path
    end

    if current_user.two_factor_backup_codes_generated?
      flash[:alert] = 'Você já viu seus códigos de backup.'
      return redirect_to set_registration_path
    end

    @backup_codes = current_user.generate_otp_backup_codes!
    current_user.save!
  end

  def destroy
    if current_user.disable_two_factor!
      flash[:notice] = 'Autenticação de dois fatores desativada com sucesso.'
      redirect_to set_registration_path
    else
      flash[:alert] = 'Não foi possível desativar a autenticação de dois fatores.'
      redirect_back fallback_location: root_path
    end
  end


  private

  def enable_2fa_params
    params.require(:two_fa).permit(:code, :password)
  end

end