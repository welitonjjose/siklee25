class OkaysController < ApplicationController
  include AccountScope
  include MedicalCertificatesFiltersConcern

  require_authentication!

  layout 'redesign'

  DEFAULT_FILTERS = {
    status: 'pending'
  }

  def index
    if current_admin
      @medical_certificates = Atestado.all.order('data_de_emissao DESC')
      @companies = Empresa.all
    elsif current_empresa
      @medical_certificates = current_empresa.atestados.order('data_de_emissao DESC')
    elsif current_funcionario.try(:employer?)
      @medical_certificates = current_funcionario.vinculos.last.empresa.atestados.order('data_de_emissao DESC')
    elsif current_funcionario.try(:manager?)
      current_vinculo = current_funcionario.vinculos.last
      @medical_certificates = Atestado.joins(:funcionario)
                                      .joins('inner join vinculos on funcionarios.id = vinculos.funcionario_id')
                                      .where('atestados.empresa_id': current_vinculo.empresa_id)
                                      .where('vinculos.squad_id': current_vinculo.squad_id)
    elsif current_funcionario
      @medical_certificates = current_funcionario.atestados.order('data_de_emissao DESC')
    elsif current_consultant
      company_ids = current_consultant.authorized_company_ids

      @medical_certificates = Atestado.where(empresa_id: company_ids).order('data_de_emissao DESC')

      @companies = Empresa.where(id: company_ids)
    elsif current_consultant_team
      company_ids = current_consultant_team.authorized_company_ids

      @medical_certificates = Atestado.where(empresa_id: company_ids).order('data_de_emissao DESC')

      @companies = Empresa.where(id: company_ids)
    end

    if company_accessible?(@companies, params[:company_id])
      @medical_certificates = @medical_certificates.where(empresa_id: params[:company_id])
      @company_id = params[:company_id]
    end

    if params[:query].present?
      @medical_certificates = @medical_certificates.global_search(params[:query])
      @query = params[:query]
    end

    params[:status] ||= DEFAULT_FILTERS[:status]

    @medical_certificates = apply_filter_by_status(params[:status], @medical_certificates)

    if params[:status] == 'pending'
      @medical_certificates = @medical_certificates.reorder('data_de_emissao ASC')
    end

    @medical_certificates = @medical_certificates.where(origem: params[:origin]) if params[:origin].present?

    @presenter = MedicalCertificatesPresenter.new(@medical_certificates)
    @employees = employees_scope

    if params[:employee_id].present?
      @medical_certificates = @medical_certificates.where(funcionario_id: params[:employee_id])
    end

    if params[:dt].present?
      @medical_certificates = @medical_certificates.where(data_de_emissao: params[:dt])
    end

    return unless request.xhr?

    render partial: 'table', locals: {
      medical_certificates: @medical_certificates,
      presenter: @presenter
    }
  end

  protected

  def set_okay
    @okay = Okay.find(params[:id])
  end

  def okay_params
    params.require(:okay).permit(:funcionario_id, :empresa_id, :content)
  end

  def company_accessible?(companies, company_id)
    return false unless company_id.present? && @companies.any?

    companies.ids.include?(company_id.to_i)
  end

  def employees_scope
    scope = Vinculo.all

    if admin? && params[:company_id].present?
      scope = scope.where(empresa_id: params[:company_id])
    elsif company?
      scope = scope.where(empresa_id: current_user.id)
    elsif employee? && (current_user.employer? || current_user.manager?)
      scope = scope.where(empresa_id: current_user.most_recent_bond.empresa_id)
    elsif consultant?
      scope = scope.where(empresa_id: current_consultant.authorized_company_ids)
    elsif collaborator?
      company_ids = fetch_company_ids(current_consultant_team)
      scope = scope.where(empresa_id: company_ids)
    else
      return []
    end

    scope.includes(:funcionario).map do |bond|
      employee = bond.funcionario

      [employee.nome, employee.id]
    end
  end

  def fetch_company_ids(resource)
    company_ids = resource.authorized_company_ids

    if params[:company_id] && company_ids.include?(params[:company_id].to_i)
      [params[:company_id]]
    else
      company_ids
    end
  end
end
