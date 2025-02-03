class ConsultantTeamsPagesController < ApplicationController
  include AccountScope

  require_consultant_user!

  before_action :set_consultant_team, only: %i[ show edit update destroy ]

  def index
    @collaborators = current_consultant.collaborators.includes(:collaborations)

    if params[:query].present?
      @collaborators = @collaborators.global_search(params[:query])
    end
  end
end
