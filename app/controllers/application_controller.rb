class ApplicationController < ActionController::Base
  # before_action :authenticate_all!, unless: :devise_controller?
  helper_method :current_app
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :verify_otp, unless: :devise_controller?
  # before_action :ensure_subdomain

  ROLES = {
    admin: :current_admin,
    employee: :current_funcionario,
    company: :current_empresa,
    consultant: :current_consultant,
    collaborator: :current_consultant_team
  }.freeze

  USER_MODEL_NAMES = {
    admin: Admin.to_s.downcase,
    employee: Funcionario.to_s.downcase,
    company: Empresa.to_s.downcase,
    consultant: Consultant.to_s.downcase,
    consultant_team: ConsultantTeam.to_s.downcase
  }.freeze

  layout :layout_by_resource

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: %i[nome cpf rg sexo data_nascimento celular razao_social cnpj telefone endereco estado cidade cep photo
                                               funcionario_lgpd registro_empresa pis vinculo empregador])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i[nome cpf rg sexo data_nascimento celular razao_social cnpj telefone endereco estado cidade cep photo
                                               funcionario_lgpd registro_empresa pis vinculo empregador])

    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
  end

  def after_sign_in_path_for(resource)
    if resource.instance_of?(Admin)
      # rails_admin_path
      root_path
    elsif resource.instance_of?(Funcionario) && resource.from_facebook?
      edit_funcionario_registration_path
    elsif resource.instance_of?(Funcionario) && !resource.funcionario_lgpd
      aceitar_lgpd_path
    elsif resource.instance_of?(Funcionario) && !resource.opt?
      new_two_factor_settings_path
    elsif redirect_to_dashboard?
      dashboard_path
    else
      new_atestado_path
    end
  end

  def toggle_empregador
    @vinculo = Vinculo.find(params[:id])
    if @vinculo.empregador
      @vinculo.update(empregador: false)
    else
      @vinculo.update(empregador: true)
    end
  end

  def toggle_gestor
    @vinculo = Vinculo.find(params[:id])
    if @vinculo.gestor
      @vinculo.update(gestor: false)
    else
      @vinculo.update(gestor: true)
    end
  end

  def current_app
    subsdomain = request.headers[:HTTP_HOST].split(".").first
    return nil if subsdomain.nil?

    @current_app = Empresa.where(subdomain: subsdomain).first
  end

  def user_by(role:)
    send("current_#{USER_MODEL_NAMES[current_role]}")
  end

  def current_role
    ROLES.each do |role, method_name|
      return role if send(method_name)
    end

    nil
  end

  def user_signed_in?
    !!current_user
  end

  def current_user
    user_method = ROLES[current_role]
    send(user_method) if user_method
  end

  def set_registration_path
    if current_user.class == ConsultantTeam
      variable_string = "edit_consultant_team_registration_path"
    elsif current_user.class == Admin
      variable_string = "rails_admin_path"
    else
      variable_string = "edit_#{current_user.class.to_s.downcase}_registration_path"
    end
    send(variable_string)
  end

  def admin?
    current_role == :admin
  end

  def employee?
    current_role == :employee
  end

  def company?
    current_role == :company
  end

  def consultant?
    current_role == :consultant
  end

  def collaborator?
    current_role == :collaborator
  end

  helper_method :user_signed_in?, :current_user, :current_role, :admin?,
                :employee?, :company?, :consultant?, :collaborator?

  def render_not_found_page
    respond_to do |format|
      format.html do
        render file: Rails.root.join('public', '404.html'), status: :not_found, layout: false
      end

      format.any { head :not_found }
    end
  end

  rescue_from ActionController::RoutingError, with: :render_not_found_page

  private

  def redirect_to_dashboard?
    company? || employee? || consultant? || collaborator?
  end

  def layout_by_resource
    if apply_login_layout?
      'login'
    else
      'application'
    end
  end

  def apply_login_layout?
    return true if devise_controller? && controller_name == 'sessions' && action_name == 'new'

    return true if devise_controller? && controller_name == 'passwords' && %(edit update).include?(action_name)

    return unless controller_name == 'password_resets' && action_name == 'new'

    return true
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def verify_otp
    return if params[:controller] == 'two_factor_settings'

    if [Funcionario, Empresa, Admin, Consultant, ConsultantTeam].any? { |klass| current_user.is_a?(klass) }
      return redirect_to new_two_factor_settings_path unless current_user.opt?
    end
  end
end
