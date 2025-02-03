class ConsultantsPagesController < ApplicationController
  include AccountScope

  require_admin!

  layout 'redesign', only: :consultants_outsourcing

  def consultants_outsourcing
    @company_id = params[:company_id]

    @links = Link.includes(:consultant)
    @consultants = []

    if @company_id.present?
      @links = @links.where(empresa_id: @company_id)

      linked_consultant_ids = @links.distinct(:consultant_id).pluck(:consultant_id)
      @consultants = Consultant.where.not(id: linked_consultant_ids)
    end
  end

  def enable_company
    consultant_id = params[:consultant_id]
    company_id = params[:company_id]

    link = create_link_for(consultant_id: consultant_id, company_id: company_id)

    if link
      @link_updated = true
      @consultant_id = consultant_id
      @company_id = company_id
    else
      @link_updated = false
    end
  end

  protected

  def create_link_for(consultant_id:, company_id:)
    return false unless consultant_id && company_id

    Link.create(
      consultant_id: consultant_id,
      empresa_id: company_id
    )
  end
end
