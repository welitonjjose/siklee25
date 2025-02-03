class MedicalCertificateCreationService
  EmployeeNotSet = Class.new(StandardError)

  DENTIST_DEFAULT_REGIONAL_STATE = 'SP'

  SPECIALTIES = {
    dentist: I18n.t(:dentist, scope: [:services, :medical_certificate_creation, :specialties])
  }

  attr_reader :medical_certificate, :user, :role

  delegate :errors, :valid?, :source_from_company_or_employer?,
    to: :medical_certificate

  alias_method :resource, :medical_certificate

  def initialize(medical_certificate_params, user:, role:)
    @user = user
    @role = role
    @medical_certificate = Atestado.new(medical_certificate_params)
  end

  def call
    begin
      assign_default_values!
    rescue EmployeeNotSet
      medical_certificate.errors.add(
        :funcionario_id, I18n.t(:not_selected, scope: 'forms.validation_errors')
      )

      return false
    end

    return false unless medical_certificate.valid?

    fill_additional_info!

    return false unless medical_certificate.save

    deliver_notifications!

    true
  end

  private

  def assign_default_values!
    if employee?
      fill_attrs_for_employee!
    elsif company?
      fill_defaults_for_company!
    end

    fill_defaults_for_dentist! if dentist_registry?
  end

  def fill_attrs_for_employee!
    medical_certificate.empresa = user.most_recent_bond.empresa

    if !employer_or_manager?
      medical_certificate.funcionario = user
    end

    assigned_employee = medical_certificate.funcionario

    raise EmployeeNotSet unless assigned_employee

    medical_certificate.nome_funcionario = assigned_employee.nome if medical_certificate.nome_funcionario.blank?
    medical_certificate.cpf_funcionario = assigned_employee.cpf if medical_certificate.cpf_funcionario.blank?
    medical_certificate.rg_funcionario = assigned_employee.rg if medical_certificate.rg_funcionario.blank?

    bond = assigned_employee.most_recent_bond

    if bond.cnpj_employee.present?
      medical_certificate.cnpj_employee = bond.cnpj_employee
    end
  end

  def fill_defaults_for_company!
    medical_certificate.funcionario_okay = false
    medical_certificate.empresa = user

    employee = Funcionario.find_by(id: medical_certificate.funcionario_id)

    if employee
      medical_certificate.nome_funcionario = employee.nome
      medical_certificate.cpf_funcionario = employee.cpf
      medical_certificate.rg_funcionario = employee.rg

      bond = employee.most_recent_bond

      if bond.cnpj_employee.present?
        medical_certificate.cnpj_employee = bond.cnpj_employee
      end
    end
  end

  def fill_defaults_for_dentist!
    medical_certificate.especialidade_medica = SPECIALTIES[:dentist]
    medical_certificate.uf_medico = DENTIST_DEFAULT_REGIONAL_STATE
  end

  def fill_additional_info!
    physician_info_updater = MedicalCertificatePhysicianInfoUpdaterService.new(medical_certificate)
    physician_info_updater.call
  end

  def deliver_notifications!
    deliver_creation_notifications! if source_from_company_or_employer?
    deliver_approval_notifications! if approved_by_employee?
  end

  def deliver_creation_notifications!
    MedicalCertificateMailer.created(medical_certificate).deliver_now
  end

  def deliver_approval_notifications!
    MedicalCertificateMailer.waiting_approval_company(medical_certificate).deliver_now
    MedicalCertificateMailer.waiting_approval_employers(medical_certificate).deliver_now
  end

  def approved_by_employee?
    medical_certificate.funcionario_okay?
  end

  def employer_or_manager?
    return false if user.vinculos.empty?

    user.employer? || user.manager?
  end

  def dentist_registry?
    medical_certificate.tipo_de_registro == Atestado::REGISTRY_TYPES[:cro]
  end

  def company?
    role == :company
  end

  def employee?
    role == :employee
  end
end
