class ConsultantTeams::RegistrationsController < Devise::RegistrationsController
  layout 'redesign'

  def create
    build_resource(consultant_team_params)

    collaboration = resource.collaborations.first

    if collaboration
      collaboration.collaborator = resource
    end

    resource.save

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def update_resource(resource, params)
    resource.update_without_password(collaborator_params_for_update)
  end

  def consultant_team_params
    params
      .require(:consultant_team)
      .permit(
        :email, :password, :password_confirmation,
        :nome, :celular, :function, :photo,
        collaborations_attributes: [:consultant_id]
      )
  end

  def collaborator_params_for_update
    params
      .require(:consultant_team)
      .permit(
        :email, :password, :password_confirmation,
        :nome, :celular, :function, :photo
      )
  end
end
