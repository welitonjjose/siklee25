class AtestadosController < ApplicationController
  include AccountScope

  require_authentication!

  require_admin! only: %i[destroy]
  require_employee! only: %i[funcionario_okay]

  require_company_manager_role! only: %i[empresa_okay atestados_funcionario],
                                third_party_access: false

  require_any_except! only: %i[
    new edit update empresa_reverter empresa_subscrever
  ], roles: %i[consultant collaborator]

  before_action :load_medical_certificate!, only: %i[
    show edit update destroy funcionario_okay
    empresa_reverter empresa_subscrever
  ]

  layout 'redesign'

  DEFAULT_MEDICAL_CERTIFICATE_TYPE = Atestado::MEDICAL_CERTIFICATE_TYPES[:default]
  DEFAULT_REPORT_TYPE = 'default'

  DEFAULT_PERMITTED_ATTRS = [
    :nome_do_medico, :tipo_de_registro, :numero_de_registro,
    :especialidade_medica, :instituicao_de_saude, :cnpj,
    :endereco, :cidade, :estado, :cep, :telefone,
    :nome_funcionario, :cpf_funcionario, :rg_funcionario,
    :acesso_funcionario, :tipo_de_atestado, :data_de_emissao,
    :data_de_apresentacao, :tempo_de_dispensa, :descricao_do_afastamento,
    :cid, :razao_social_id, :funcionario_okay, :empresa_okay, :medico_examinador,
    :examinador_registro, :examinador_numero_registro, :cfm_photo, :funcionario_id,
    :cfm, :uf_medico, :uf_examinador, :exames, :exames_complementares,
    :origem, :empresa_subscrever, :empresa_reverter, :funcionario_corrigir,
    { photos: [] }
  ]

  NOT_FOUND_PHYSICIAN_VALUE = 'Não encontrado'

  def index
    @atestados =  medical_certificates_scope
    @physician_names = physician_names(@atestados)
    @medical_specialties = medical_specialties(@atestados)
    @icds = icds_for(@atestados)
    @medical_institutions = medical_institutions(@atestados)
    @departments = departments_for
    @job_functions = job_functions_for(@atestados)

    if params[:medical_certificate_type].present?
      medical_certificate_type = params[:medical_certificate_type]

      stored_medical_certificate_type = Atestado::MEDICAL_CERTIFICATE_TYPES[medical_certificate_type]

      @atestados = @atestados.where(tipo_de_atestado: medical_certificate_type)
    else
      stored_medical_certificate_type = DEFAULT_MEDICAL_CERTIFICATE_TYPE
    end

    @atestados = apply_filter_by_absence_reason_for_default(
      params[:by_absence_reason].to_sym, @atestados
    ) unless params[:by_absence_reason].nil? || params[:by_absence_reason] == ''

    if params[:employee_id].present?
      @atestados = @atestados.where(funcionario_id: params[:employee_id])

      employee = @atestados.first.try(:funcionario)
      @job_risk = employee.risco_ocupacional if employee
    end

    @atestados = @atestados.where(nome_do_medico: params[:physician_name]) if params[:physician_name].present?

    if params[:medical_specialty].present?
      @atestados = @atestados.where(especialidade_medica: params[:medical_specialty])
    end

    @atestados = @atestados.where(cid: params[:icd]) if params[:icd].present?

    if params[:medical_institution].present?
      @atestados = @atestados.where(instituicao_de_saude: params[:medical_institution])
    end

    @atestados = @atestados.where(origem: params[:origin]) if params[:origin].present?

    if params[:employee_status].present?
      filtered_employee_ids =
        Vinculo.where(
          funcionario_id: @atestados.pluck(:funcionario_id),
          ativo: params[:employee_status] == 'active'
        ).pluck(:funcionario_id)

      @atestados = @atestados.where(funcionario_id: filtered_employee_ids)
    end

    if params[:department].present?
      filtered_employee_ids = Vinculo.where(
        funcionario_id: @atestados.pluck(:funcionario_id),
        squad: params[:department]
      ).pluck(:funcionario_id)

      @atestados = @atestados.where(funcionario_id: filtered_employee_ids)
    end

    if params[:job_function].present?
      filtered_employee_ids = Vinculo.where(
        funcionario_id: @atestados.pluck(:funcionario_id),
        cargo: params[:job_function]
      ).pluck(:funcionario_id)

      @atestados = @atestados.where(funcionario_id: filtered_employee_ids)
    end

    if params[:funcionario_lider_id].present?
      filtered_employee_leader_ids = Vinculo.where(
        funcionario_lider_id: @atestados.pluck(:funcionario_id),
        funcionario_lider_id: params[:funcionario_lider_id]
      ).pluck(:funcionario_id)
      @atestados = @atestados.where(funcionario_id: filtered_employee_leader_ids)
    end
    @employees = employees_scope

    if params[:range_start].present? || params[:range_end].present?
      range_start = params[:range_start].to_date || Time.now - 30.day
      range_end  = params[:range_end].to_date || Time.now
      @atestados =@atestados.where(created_at: range_start.beginning_of_day..range_end.end_of_day)
    end

    @pending_medical_certificates_count = @atestados.where(funcionario_okay: false).or(
      @atestados.where(empresa_okay: false)
    ).count

    @company_pending_medical_certificates_count = @atestados.where(empresa_okay: false).count
    @employee_pending_medical_certificates_count = @atestados.where(funcionario_okay: false).count


    adid = Atestado.absence_duration_in_days(@atestados)
    adid = 0 if adid == 1 && params[:medical_certificate_type] == "Atestado de Saude Ocupacional (ASO)"

    @absence_duration_in_days = adid
    @receiving_average_in_days = Atestado.receiving_average_in_days(@atestados)


    if params[:query].present?
      @atestados = @atestados.global_search_gestor(params[:query])
    else
      respond_to do |format|
        format.html

        format.xlsx

        format.csv do
          csv_report = MedicalCertificatesReport.csv(@atestados, params[:date])

          send_data csv_report, filename: "atestados-#{Date.today}.csv"
        end

        format.xml do
          @atestados = @atestados.company_approved
                                 .where('data_de_emissao > ?', 30.days.ago)

          report_type = params[:report_type] || DEFAULT_REPORT_TYPE

          case report_type
          when 'default'
            xml_report = MedicalCertificatesReport.xml(@atestados)
          when 'esocial'
            xml_report = MedicalCertificatesEsocialReport.xml(@atestados)
          end

          filename_suffix = report_type == 'default' ? '' : 'esocial-'

          send_data xml_report, filename: "atestados-#{filename_suffix}#{Date.today}.xml"
        end
      end
    end

  end

  def atestados_funcionario
    if admin?
      @funcionario = Funcionario.find(params[:id])
    elsif company?
      @funcionario = current_user.funcionarios.find_by_id(params[:id])
    end

    return render_not_found_page unless @funcionario

    @atestados = Atestado.where(funcionario_id: @funcionario.id)
                         .where(empresa_id: current_user.authorized_company_ids)
                         .order('data_de_emissao DESC')
  end

  def show
  end

  def new
    redirect_to aceitar_lgpd_path unless current_funcionario&.funcionario_lgpd || current_empresa || current_admin

    @atestado = Atestado.new

    if current_funcionario && !current_funcionario.employer? && !current_funcionario.manager?
      @atestado.funcionario = current_funcionario
    end

    if current_empresa
      @atestado.empresa = current_empresa
    elsif current_funcionario && (current_funcionario.employer? || current_funcionario.manager?)
      @atestado.empresa = current_funcionario.vinculos.last.empresa
      @vinculo = current_funcionario.vinculos.last.empresa
    end

    flash.now[:notice] = t('.reminders.medical_certificate_photo')
  end

  def edit
    flash[:alert] = "Revise o atestado clicando no 'Tipo de Atestado'"

    @atestado.nome_funcionario = @atestado.funcionario&.nome if @atestado.nome_funcionario.blank?
    @atestado.cpf_funcionario = @atestado.funcionario&.cpf if @atestado.cpf_funcionario.blank?
    @atestado.rg_funcionario = @atestado.funcionario&.rg if @atestado.rg_funcionario.blank?
  end

  def create
    creation_service = MedicalCertificateCreationService.new(atestado_params,
                                                             user: current_user,
                                                             role: current_role)

    if creation_service.call
      redirect_to atestados_path, notice: 'Atestado enviado com sucesso!'
    else
      @atestado = creation_service.resource

      if current_funcionario && !current_funcionario.employer? && !current_funcionario.manager?
        @atestado.funcionario = current_funcionario
      end

      if current_empresa
        @atestado.empresa = current_empresa
      elsif current_funcionario && (current_funcionario.employer? || current_funcionario.manager?)
        @atestado.empresa = current_funcionario.vinculos.last.empresa
        @vinculo = current_funcionario.vinculos.last.empresa
      end

      render :new
    end
  end

  def update
    updater_service = MedicalCertificateUpdaterService.new(params[:id])

    if updater_service.call(medical_certificate_update_params)
      redirect_to atestados_path, notice: 'Atestado atualizado com sucesso!'
    else
      @atestado = updater_service.resource

      render :edit
    end
  end

  def empresa_okay
    @atestado = Atestado.find(params[:id])

    if @atestado.empresa_subscrever?
      flash[:notice] = 'Atestado já foi subscrito!'
    elsif @atestado.update(empresa_okay: true)
      MedicalCertificateMailer.approved(@atestado).deliver_now

      flash[:notice] = 'Atestado aprovado com sucesso!'
    else
      flash[:notice] = 'Não foi possível aprovar o atestado, por favor tente novamente.'
    end

    redirect_to okays_path
  end

  def empresa_subscrever
    return render_not_found_page if employee? && !current_user.employer?

    if @atestado.empresa_okay?
      redirect_to okays_path, notice: t('.already_approved')
    elsif @atestado.update(empresa_subscrever: true)
      MedicalCertificateMailer.annulled(@atestado).deliver_now

      redirect_to new_atestado_path, notice: t('.success')
    else
      redirect_to atestados_path, notice: t('.error')
    end
  end

  def empresa_reverter
    return render_not_found_page if employee? && !current_user.employer?

    message = t('.error')

    if @atestado.empresa_okay?
      message = t('.already_approved')
    elsif @atestado.empresa_subscrever?
      message = t('.already_annulled')
    elsif @atestado.update(empresa_reverter: true)
      MedicalCertificateMailer.reverted(@atestado).deliver_now

      message = t('.success')
    end

    redirect_to okays_path, notice: message
  end

  def funcionario_okay
    message = t('.error')

    if @atestado.update(funcionario_okay: true)
      MedicalCertificateMailer.waiting_approval_company(@atestado).deliver_now
      MedicalCertificateMailer.waiting_approval_employers(@atestado).deliver_now

      message = t('.success')
    end

    redirect_to okays_path, notice: message
  end

  def destroy
    @atestado.destroy
    redirect_to atestados_path, notice: 'Atestado deletado com sucesso!'
  end

  protected

  def load_medical_certificate!
    if current_user.try(:manager?)
      current_vinculo = current_user.vinculos.last
      @atestado = Atestado.joins(:funcionario)
                          .joins('inner join vinculos on funcionarios.id = vinculos.funcionario_id')
                          .where('atestados.empresa_id': current_vinculo.empresa_id)
                          .where('vinculos.squad_id': current_vinculo.squad_id)
                          .find_by_id(params[:id])
    else
      @atestado = current_user&.atestados&.find_by_id(params[:id])
    end

    return if @atestado

    render_not_found_page
  end

  def atestado_params
    permitted_attrs = DEFAULT_PERMITTED_ATTRS

    permitted_attrs.concat(%i[empresa_id funcionario_id]) if current_admin

    params.require(:atestado).permit(permitted_attrs)
  end

  def medical_certificate_update_params
    permitted_attrs = %i[
      tipo_de_atestado tipo_de_registro numero_de_registro
      examinador_registro examinador_numero_registro cnpj
      instituicao_de_saude data_de_emissao tempo_de_dispensa
      cid descricao_do_afastamento exames exames_complementares
    ]

    permitted_attrs << { photos: [] }

    if current_funcionario
      permitted_attrs.concat %i[funcionario_corrigir]
    elsif current_empresa
      permitted_attrs.concat %i[empresa_okay]
    end

    params.require(:atestado).permit(permitted_attrs)
  end

  def medical_certificates_scope
    if admin?
      scope = Atestado.all

      @companies = Empresa.all

      scope = scope.where(empresa_id: params[:company_id]) if params[:company_id].present?
    elsif company?
      scope = current_empresa.atestados
    elsif employee? && current_funcionario.employer?
      scope = current_funcionario.most_recent_bond.empresa.atestados
    elsif employee? && current_funcionario.manager?
      current_vinculo = current_funcionario.vinculos.last
      scope = Atestado.joins(:funcionario)
                      .joins('inner join vinculos on funcionarios.id = vinculos.funcionario_id')
                      .where('atestados.empresa_id': current_vinculo.empresa_id)
                      .where('vinculos.squad_id': current_vinculo.squad_id)
    elsif employee?
      scope = current_funcionario.atestados
    elsif consultant?
      company_ids = fetch_company_ids(current_consultant)

      scope = Atestado.where(empresa_id: company_ids)

      @companies = Empresa.where(id: current_consultant.authorized_company_ids)
    elsif collaborator?
      company_ids = fetch_company_ids(current_consultant_team)

      scope = Atestado.where(empresa_id: company_ids)

      @companies = Empresa.where(id: company_ids)
    end

    scope.order(data_de_emissao: :desc)
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

  def physician_names(medical_certificates)
    medical_certificate_counts = medical_certificates.reorder('').group(:numero_de_registro).count

    doctors = medical_certificates.where.not(nome_do_medico: [nil, ''])
                                  .pluck(:nome_do_medico, :numero_de_registro)
                                  .uniq

    names = doctors.map do |name, registry|
      next if name == NOT_FOUND_PHYSICIAN_VALUE

      if registry.present?
        [
          "#{name} (#{registry}) - 🗒️ #{medical_certificate_counts[registry]}",
          name
        ]
      else
        [name, name]
      end
    end.compact

    names << [NOT_FOUND_PHYSICIAN_VALUE, NOT_FOUND_PHYSICIAN_VALUE] if doctors.any? do |infos|
      infos.include? NOT_FOUND_PHYSICIAN_VALUE
    end

    names
  end

  def medical_specialties(medical_certificates)
    medical_certificates.where.not(especialidade_medica: [nil, ''])
                        .pluck(:especialidade_medica)
                        .uniq
  end

  def icds_for(medical_certificates)
    medical_certificates.where.not(cid: [nil, ''])
                        .pluck(:cid)
                        .uniq
  end

  def medical_institutions(medical_certificates)
    medical_certificates.where.not(instituicao_de_saude: [nil, ''])
                        .pluck(:instituicao_de_saude)
                        .uniq
  end

  def departments_for
    squad_scope = Squad.select('id, name')

    if current_empresa
      squad_scope = squad_scope.where(empresa_id: current_empresa.id)
    elsif current_funcionario
      squad_scope = squad_scope.where(id: current_funcionario.vinculos.last.squad_id)
    elsif params[:company_id].present?
      squad_scope = squad_scope.where(empresa_id: params[:company_id])
    else
      squad_scope = squad_scope.where(id: -1)
    end
  end

  def job_functions_for(medical_certificates)
    Vinculo.where(funcionario_id: medical_certificates.pluck(:funcionario_id))
           .pluck(:cargo)
           .uniq
  end

  def fetch_company_ids(resource)
    company_ids = resource.authorized_company_ids

    if params[:company_id] && company_ids.include?(params[:company_id].to_i)
      [params[:company_id]]
    else
      company_ids
    end
  end

  def apply_filter_by_absence_reason_for_default(absence_reason, scope)
    scope.where(
      tipo_de_atestado: Atestado::MEDICAL_CERTIFICATE_TYPES[:default],
      descricao_do_afastamento: Atestado::ABSENCE_REASONS_FOR_DEFAULT[absence_reason]
    )
  end
end
