class ConsultantsController < ApplicationController
  include AccountScope

  require_company_user!

  layout 'redesign'

  def index
    @consultants = current_empresa.approved_consultants
  end
end
