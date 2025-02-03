class CompaniesController < ApplicationController
  include AccountScope

  require_admin_or_consultant_user! only: :employees

  def employees
    @employees = Funcionario.joins(:vinculos).where('vinculos.empresa_id = ? and vinculos.ativo = true', params[:id])

    render formats: :json
  end
end
