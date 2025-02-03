class Funcionarios::RegistrationsController < Devise::RegistrationsController
  before_action :deny_registration, only: %i[new create]

  layout 'redesign', only: %i[edit update]

  protected

  def deny_registration
    redirect_to root_path, alert: t(:not_allowed, scope: 'funcionarios.registrations')
  end

  def update_resource(resource, params)
    resource.update_without_password(params)
  end
end
