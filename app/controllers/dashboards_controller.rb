class DashboardsController < ApplicationController
  include AccountScope
  include MedicalCertificatesFiltersConcern

  require_authentication!

  layout 'redesign'

  DEFAULT_DATE_FORMAT = '%d/%m/%Y'

  def show
    @departments_filters = []
     @active_departaments = 0
    if current_user.kind_of? Funcionario
      # squads = Squad.where(id: current_user.most_recent_bond.squad_id)
      # @active_departaments =  squads.count
      @active_departaments = 1
    end

    if admin?
      @total_employees_path = funcionarios_pages_path
      @total_employees_scope = Vinculo
      @active_departaments =  Squad.count

      medical_certificates_scope = Atestado.all
      @companies = Empresa.all

      if params[:company_id].present?
        medical_certificates_scope = medical_certificates_scope.where(
          empresa_id: params[:company_id]
        )
        @total_employees_scope = @total_employees_scope.where(empresa_id: params[:company_id])

        @active_departaments = Squad.where(empresa_id: params[:company_id]).count
      end

      if params[:departament].present?

        @total_employees_scope = @total_employees_scope.where(squad_id: params[:departament])

        @active_departaments = Squad.where(id: params[:departament]).count
      end

      @total_employees = @total_employees_scope.count

    elsif company?
      @total_employees_path = empresas_pages_path
      @total_employees_scope = Vinculo.where(empresa_id: current_empresa.id)
      if params[:departament].present?
        @active_departaments =  Squad.where(id: params[:departament]).count
        @total_employees_scope = @total_employees_scope.where(squad_id: params[:departament])
      else
        @active_departaments =  Squad.where(empresa_id: current_empresa).count
      end

      @total_employees = @total_employees_scope.count
      medical_certificates_scope = current_user.atestados

    elsif employee? && (current_user.employer?)
      @total_employees_path = funcionarios_pages_path
      active_bond = current_user.most_recent_bond

      @total_employees_scope = Vinculo.where(empresa_id: active_bond.empresa_id)

      medical_certificates_scope = Atestado.joins(:funcionario)
                                           .joins('inner join vinculos on funcionarios.id = vinculos.funcionario_id')
                                           .where('atestados.empresa_id': active_bond.empresa_id)
                                           .where('vinculos.squad_id': active_bond.squad_id)
      if params[:departament].present?
        @active_departaments =  Squad.where(id: params[:departament]).count
        @total_employees_scope = @total_employees_scope.where(squad_id: params[:departament])
      else
        @active_departaments =  Squad.where(empresa_id: current_user.most_recent_bond.empresa_id).count
      end

      @total_employees = @total_employees_scope.count
      medical_certificates_scope = current_user.atestados

    elsif employee? && (current_user.manager?)
      active_bond = current_user.most_recent_bond

      @total_employees = Vinculo.where(empresa_id: active_bond.empresa_id)
                                .where(squad_id: active_bond.squad_id)
                                .count

      medical_certificates_scope = Atestado.joins(:funcionario)
                                           .joins('inner join vinculos on funcionarios.id = vinculos.funcionario_id')
                                           .where('atestados.empresa_id': active_bond.empresa_id)
                                           .where('vinculos.squad_id': active_bond.squad_id)
    elsif employee?
      @total_employees = 1

      @active_patients = Atestado.exists?(funcionario_id: current_user.id) ? 1 : 0

      medical_certificates_scope = Atestado.where(funcionario_id: current_user.id)
    
    elsif consultant?
      @total_employees_path = funcionarios_pages_path
      company_ids = fetch_company_ids(current_consultant)
      @total_employees_scope = Vinculo.where(empresa_id: company_ids)

      @total_employees = Vinculo.where(empresa_id: company_ids).count if company_ids.any?

      medical_certificates_scope = Atestado.where(empresa_id: company_ids)
      @companies = Empresa.where(id: current_consultant.authorized_company_ids)
      @active_departaments = Squad.where(empresa_id: current_consultant.authorized_company_ids).count

      if params[:company_id].present?
        @active_departaments = Squad.where(empresa_id: params[:company_id]).count
        @total_employees_scope = @total_employees_scope.where(empresa_id: params[:company_id])
      end

      if params[:departament].present?
        @active_departaments = Squad.where(id: params[:departament]).count
        @total_employees_scope = @total_employees_scope.where(squad_id: params[:departament])
      end

      @total_employees = @total_employees_scope.where(empresa_id: current_consultant.authorized_company_ids).count

    elsif collaborator?
      @total_employees_path = funcionarios_pages_path
      company_ids = fetch_company_ids(current_consultant_team)
      @total_employees_scope = Vinculo.where(empresa_id: company_ids)

      @total_employees = Vinculo.where(empresa_id: company_ids).count if company_ids.any?

      medical_certificates_scope = Atestado.where(empresa_id: company_ids)
      @companies = Empresa.where(id: company_ids)
      @active_departaments = Squad.where(empresa_id: current_consultant_team.authorized_company_ids).count

      if params[:company_id].present?
        @active_departaments = Squad.where(empresa_id: params[:company_id]).count
        @total_employees_scope = @total_employees_scope.where(empresa_id: params[:company_id])
      end

      if params[:departament].present?
        @active_departaments = Squad.where(id: params[:departament]).count
        @total_employees_scope = @total_employees_scope.where(squad_id: params[:departament])
      end

      @total_employees = @total_employees_scope.where(empresa_id: current_consultant_team.authorized_company_ids).count
    end


    medical_certificates_scope = apply_filter_by_period(
      medical_certificates_scope, params[:period_from], params[:period_to]
    )

    medical_certificates_scope = apply_filter_by_company(
      medical_certificates_scope, params[:company_id]
    )

    medical_certificates_scope = apply_filter_by_type(
      params[:medical_certificate_type], medical_certificates_scope
    )

    medical_certificates_scope = apply_filter_by_origin(
      params[:origin].to_sym, medical_certificates_scope
    ) unless params[:origin].nil? || params[:origin] == ''

    medical_certificates_scope = apply_filter_by_absence_reason_for_default(
      params[:by_absence_reason].to_sym, medical_certificates_scope
    ) unless params[:by_absence_reason].nil? || params[:by_absence_reason] == ''

    medical_certificates_scope = apply_filter_by_departaments(
      params[:departament], medical_certificates_scope
    ) unless params[:departament].nil? || params[:departament] == ''

    @active_patients ||= medical_certificates_scope.distinct.count(:funcionario_id)
    @total_medical_certificates = medical_certificates_scope.count
    @receiving_average_in_days = Atestado.receiving_average_in_days(medical_certificates_scope)

    adid = Atestado.absence_duration_average_in_days(
      medical_certificates_scope
    )
    adid = 0 if adid == 1 && params[:medical_certificate_type] == "aso"
    @absence_duration_average_in_days = adid

    @highest_issuer_in_percentage = Atestado.highest_issuer_in_percentage(
      medical_certificates_scope, @total_medical_certificates
    )

    @receiving_range_peaks = medical_certificates_scope.receiving_range_peaks

    @absence_duration_range_peaks = Atestado.absence_duration_range_peaks(
      medical_certificates_scope
    )

    pending_medical_certificates_scope = apply_filter_by_status('pending', medical_certificates_scope)
    @total_pending_medical_certificates = pending_medical_certificates_scope.count
    @pending_receiving_range_peaks = pending_medical_certificates_scope.receiving_range_peaks

    @pending_absence_duration_range_peaks = Atestado.absence_duration_range_peaks(
      pending_medical_certificates_scope
    )

    approved_medical_certificates_scope = apply_filter_by_status('approved', medical_certificates_scope)
    @total_approved_medical_certificates = approved_medical_certificates_scope.count
    @approved_receiving_range_peaks = approved_medical_certificates_scope.receiving_range_peaks

    @approved_absence_duration_range_peaks = Atestado.absence_duration_range_peaks(
      approved_medical_certificates_scope
    )

    annulled_medical_certificates_scope = apply_filter_by_status('annulled', medical_certificates_scope)
    @total_annulled_medical_certificates = annulled_medical_certificates_scope.count
    @annulled_receiving_range_peaks = annulled_medical_certificates_scope.receiving_range_peaks

    @annulled_absence_duration_range_peaks = Atestado.absence_duration_range_peaks(
      annulled_medical_certificates_scope
    )


    edited_medical_certificates_scope = apply_filter_by_status('edited', medical_certificates_scope)
    @total_edited_medical_certificates = edited_medical_certificates_scope.count
    @edited_receiving_range_peaks = edited_medical_certificates_scope.receiving_range_peaks

    @edited_absence_duration_range_peaks = Atestado.absence_duration_range_peaks(
      edited_medical_certificates_scope
    )

    reverted_medical_certificates_scope = apply_filter_by_status('reverted', medical_certificates_scope)
    @total_reverted_medical_certificates = reverted_medical_certificates_scope.count
    @reverted_receiving_range_peaks = reverted_medical_certificates_scope.receiving_range_peaks

    @reverted_absence_duration_range_peaks = Atestado.absence_duration_range_peaks(
      reverted_medical_certificates_scope
    )


    created_by_employee_medical_certificates_scope = apply_filter_by_origin(:employee, medical_certificates_scope)
    @total_employee_medical_certificates = created_by_employee_medical_certificates_scope.count
    @created_by_employee_receiving_range_peaks = created_by_employee_medical_certificates_scope.receiving_range_peaks

    @created_by_employee_absence_duration_range_peaks = Atestado.absence_duration_range_peaks(
      created_by_employee_medical_certificates_scope
    )

    created_by_company_medical_certificates_scope = apply_filter_by_origin(:company, medical_certificates_scope)
    @total_company_medical_certificates = created_by_company_medical_certificates_scope.count
    @created_by_company_receiving_range_peaks = created_by_company_medical_certificates_scope.receiving_range_peaks

    @created_by_company_absence_duration_range_peaks = Atestado.absence_duration_range_peaks(
      created_by_company_medical_certificates_scope
    )

    created_by_gestor_medical_certificates_scope = apply_filter_by_origin(:gestor, medical_certificates_scope)
    @total_gestor_medical_certificates = created_by_gestor_medical_certificates_scope.count
    @created_by_gestor_receiving_range_peaks = created_by_gestor_medical_certificates_scope.receiving_range_peaks

    @created_by_gestor_absence_duration_range_peaks = Atestado.absence_duration_range_peaks(
      created_by_gestor_medical_certificates_scope
    )


    if not_filtering_or_by_given_type?(params[:medical_certificate_type], :presence)
      presence_medical_certificates_scope = apply_filter_by_type(:presence, medical_certificates_scope)
      @total_presence_statement_of_hours = presence_medical_certificates_scope.count

      @presence_statement_of_hours_range_peaks = Atestado.absence_duration_range_peaks(
        presence_medical_certificates_scope,
        format: :hours
      )

      @presence_statement_of_hours_receiving_range_peaks = presence_medical_certificates_scope.receiving_range_peaks
    end

    if not_filtering_or_by_given_type?(params[:medical_certificate_type], :accompany)
      accompany_medical_certificates_scope = apply_filter_by_type(:accompany, medical_certificates_scope)
      @total_accompany_statement_of_hours = accompany_medical_certificates_scope.count

      @accompany_statement_of_hours_range_peaks = Atestado.absence_duration_range_peaks(
        accompany_medical_certificates_scope,
        format: :hours
      )

      @accompany_statement_of_hours_receiving_range_peaks = accompany_medical_certificates_scope.receiving_range_peaks
    end

    if not_filtering_or_by_given_type?(params[:medical_certificate_type], :default)
      sickness_medical_certificates_scope = apply_filter_by_absence_reason_for_default(
        :sickness, medical_certificates_scope
      )

      @total_sickness_statement_of_days = sickness_medical_certificates_scope.count

      @sickness_statement_of_days_range_peaks = Atestado.absence_duration_range_peaks(
        sickness_medical_certificates_scope
      )

      @sickness_statement_of_days_receiving_range_peaks = sickness_medical_certificates_scope.receiving_range_peaks

      work_accident_medical_certificates_scope = apply_filter_by_absence_reason_for_default(
        :work_accident, medical_certificates_scope
      )

      @total_work_accident_statement_of_days = work_accident_medical_certificates_scope.count

      @work_accident_statement_of_days_range_peaks = Atestado.absence_duration_range_peaks(
        work_accident_medical_certificates_scope
      )

      @work_accident_statement_of_days_receiving_range_peaks = work_accident_medical_certificates_scope.receiving_range_peaks

      traffic_accident_medical_certificates_scope = apply_filter_by_absence_reason_for_default(
        :traffic_accident, medical_certificates_scope
      )

      @total_traffic_accident_statement_of_days = traffic_accident_medical_certificates_scope.count

      @traffic_accident_statement_of_days_range_peaks = Atestado.absence_duration_range_peaks(
        traffic_accident_medical_certificates_scope
      )

      @traffic_accident_statement_of_days_receiving_range_peaks =
        traffic_accident_medical_certificates_scope.receiving_range_peaks

      maternity_leave_medical_certificates_scope = apply_filter_by_absence_reason_for_default(
        :maternity_leave, medical_certificates_scope
      )

      @total_maternity_leave_statement_of_days = maternity_leave_medical_certificates_scope.count

      @maternity_leave_statement_of_days_range_peaks = Atestado.absence_duration_range_peaks(
        maternity_leave_medical_certificates_scope
      )

      @maternity_leave_statement_of_days_receiving_range_peaks =
        maternity_leave_medical_certificates_scope.receiving_range_peaks
    end
  end

  protected

  def apply_filter_by_origin(source, scope)
    case source
    when :employee
      scope.where(origem: 'funcionario')
    when :company
      scope.where(origem: 'empresa')
    when :gestor
      scope.where(origem: 'gestor')
    end
  end

  def apply_filter_by_type(type, scope)
    return scope if type.blank?

    type = type.to_sym

    return scope if Atestado::MEDICAL_CERTIFICATE_TYPES[type].blank?

    scope.where(
      tipo_de_atestado: Atestado::MEDICAL_CERTIFICATE_TYPES[type]
    )
  end

  def apply_filter_by_absence_reason_for_default(absence_reason, scope)
    scope.where(
      tipo_de_atestado: Atestado::MEDICAL_CERTIFICATE_TYPES[:default],
      descricao_do_afastamento: Atestado::ABSENCE_REASONS_FOR_DEFAULT[absence_reason]
    )
  end

  def apply_filter_by_departaments(departament, scope)
    scope.joins('inner join vinculos vq on atestados.funcionario_id = vq.funcionario_id')
         .where("vq.squad_id = ?", departament)
  end

  def apply_filter_by_period(scope, from, to)
    return scope if from.blank? || to.blank?

    begin
      from = Date.strptime(from, DEFAULT_DATE_FORMAT)
      to = Date.strptime(to, DEFAULT_DATE_FORMAT)
    rescue ArgumentError
      params[:period_from] = nil
      params[:period_to] = nil

      return scope
    end

    if from > to
      params[:period_from] = nil
      params[:period_to] = nil

      return scope
    end

    scope.where(data_de_emissao: from..to)
  end

  def apply_filter_by_company(scope, company_id)
    return scope if company_id.blank?
    return scope unless admin? || consultant? || collaborator?

    scope.where(empresa_id: company_id)
  end

  def fetch_company_ids(resource)
    company_ids = resource.authorized_company_ids

    if params[:company_id] && company_ids.include?(params[:company_id].to_i)
      [params[:company_id]]
    else
      company_ids
    end
  end

  def not_filtering_or_by_given_type?(filtered_type, type)
    filtered_type.blank? || filtered_type.to_sym == type
  end
end
