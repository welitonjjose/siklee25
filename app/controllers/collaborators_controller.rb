class CollaboratorsController < ApplicationController
  include AccountScope

  require_consultant_user!

  layout 'redesign', only: :index

  def index
    @collaborators = current_consultant.collaborators
    @authorized_collaborator_ids = Collaboration.where(consultant: current_consultant).
      approved.pluck(:collaborator_id)

    if params[:query].present?
      @collaborators = @collaborators.global_search(params[:query])
    end
  end

  def authorize
    collaborator_id = params['id']

    collaboration = find_collaboration(collaborator_id: collaborator_id, status: :pending)

    if collaboration && collaboration.update(status: :approved)
      flash[:notice] = t('.success')
    else
      flash[:notice] = t('.error')
    end

    redirect_to collaborators_path
  end

  def revoke
    collaborator_id = params['id']

    collaboration = find_collaboration(collaborator_id: collaborator_id, status: :approved)

    if collaboration && collaboration.update(status: :pending)
      flash[:notice] = t('.success')
    else
      flash[:notice] = t('.error')
    end

    redirect_to collaborators_path
  end

  protected

  def find_collaboration(collaborator_id:, status:)
    Collaboration.find_by(consultant: current_consultant,
                          collaborator_id: collaborator_id,
                          status: status)
  end
end
