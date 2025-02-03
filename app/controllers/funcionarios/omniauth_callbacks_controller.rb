class Funcionarios::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    funcionario = Funcionario.from_omniauth(request.env['omniauth.auth'])

    if funcionario.persisted?
      sign_in_and_redirect funcionario, event: :authentication
      set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
    else
      session['devise.facebook_data'] = request.env['omniauth.auth']
      redirect_to new_funcionario_registration_url
    end
  end
end
