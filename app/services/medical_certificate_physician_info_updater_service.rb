class MedicalCertificatePhysicianInfoUpdaterService
  NOT_FOUND = I18n.t(:not_found, scope: [:services, :medical_certificate_physician_info_updater])

  attr_reader :medical_certificate

  def initialize(medical_certificate)
    @medical_certificate = medical_certificate
  end

  def call
    fetch_and_fill_data_for_doctor
    fetch_and_fill_data_for_examining_physician if medical_certificate.aso?

    true
  end

  private

  def fetch_and_fill_data_for_doctor
    return if medical_certificate.numero_de_registro.blank?

    case 
    when medical_certificate.crm_registered?
      result = fetch_data_for_crm_doctor 
    when medical_certificate.cro_registered?
      result = fetch_data_for_cro_doctor 
    else
      OpenStruct.new(success?: false)
    end

    if result.success?
      fill_data_for_doctor(result.data)
    else
      fill_data_for_doctor({
        nome: NOT_FOUND,
        uf: NOT_FOUND,
        especialidade: NOT_FOUND,
        situacao: NOT_FOUND
      })
    end
  end

  def fetch_data_for_crm_doctor
     fetch_cfm_data_for(doctor_registry: medical_certificate.numero_de_registro)
  end

  def fetch_data_for_cro_doctor
    fetch_cro_data_for(doctor_registry: medical_certificate.numero_de_registro)
  end

  def fill_data_for_doctor(info)
    medical_certificate.nome_do_medico = info[:nome]
    medical_certificate.uf_medico = info[:uf]

    medical_certificate.especialidade_medica = find_medical_specialty(info)
    medical_certificate.physician_status_on_cfm = find_physician_status(info)
  end

  def find_medical_specialty(info)
    medical_specialty = info.fetch(:especialidade, [])

    case
    when medical_specialty.is_a?(Array) && medical_specialty.any?
      medical_specialty.join("\n")
    when !medical_specialty.blank?
      medical_specialty
    else
      NOT_FOUND
    end
  end

  def find_physician_status(info)
    if medical_certificate.crm_registered?
      status = ConselhoFederalMedicinaApi.physician_status(info[:situacao])

      return CfmPhysicianStatuses::NOT_FOUND unless status

      CfmPhysicianStatuses.value_for(status.to_s.upcase)
    elsif medical_certificate.cro_registered?
      status = ConselhoRegionalOdontologiaApi.physician_status(info[:situacao])

      return CroPhysicianStatuses::NOT_FOUND unless status

      CroPhysicianStatuses.value_for(status.to_s.upcase)
    end
  end

  def fetch_and_fill_data_for_examining_physician
    return unless medical_certificate.examinador_registro == Atestado::REGISTRY_TYPES[:crm]
    return if medical_certificate.examinador_numero_registro.blank?

    result = fetch_cfm_data_for(doctor_registry: medical_certificate.examinador_numero_registro)

    if result.success?
      fill_data_for_examining_physician(result.data)
    else
      fill_data_for_examining_physician({
        nome: NOT_FOUND,
        uf: NOT_FOUND,
        situacao: NOT_FOUND
      })
    end
  end

  def fill_data_for_examining_physician(info)
    medical_certificate.medico_examinador = info[:nome]
    medical_certificate.uf_examinador = info[:uf]
    medical_certificate.examining_physician_status_on_cfm = find_physician_status(info)
  end

  def fetch_cfm_data_for(doctor_registry:)
    ConselhoFederalMedicinaApi.get_doctor_by(
      crm: Atestado.crm_number(doctor_registry),
      uf: Atestado.crm_region(doctor_registry)
    )
  end

  def fetch_cro_data_for(doctor_registry:)
    ConselhoRegionalOdontologiaApi.get_doctor_by(
      cro: Atestado.cro_number(doctor_registry),
      uf: Atestado.cro_region(doctor_registry)
    )
  end
end
