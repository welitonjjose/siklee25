class PasswordResetsController < ApplicationController
  def new
  end

  def create
    funcionario = Funcionario.find_by_email(params[:email])
    funcionario.send_reset_password_instructions if funcionario

    flash[:notice] = t('devise.passwords.send_instructions')

    redirect_to new_funcionario_session_path
  end

  def edit
    @funcionario = Funcionario.find_by_password_reset_token!(params[:id])
  end

  def update
    @funcionario = Funcionario.find_by_password_reset_token!(params[:id])
    if @funcionario.password_reset_sent_at < 2.hour.ago
      flash[:notice] = 'Password reset has expired'
      redirect_to new_password_reset_path
    elsif @funcionario.update(funcionario_params)
      flash[:notice] = 'Password has been reset!'
      redirect_to new_funcionario_session_path
    else
      render :edit
    end
  end

  private

  def funcionario_params
    params.require(:funcionario).permit(:password)
  end
end
