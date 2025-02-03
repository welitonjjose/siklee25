class MedicalCertificateUpdaterService
  REGISTRY_NUMBER_FIELDS = {
    physician: :numero_de_registro
  }

  attr_reader :medical_certificate, :changes

  alias_method :resource, :medical_certificate

  delegate :changes, to: :resource

  def initialize(id)
    @medical_certificate = Atestado.find(id)
    @changes = {}
  end

  def call(params)
    medical_certificate.assign_attributes(params)

    @changes = medical_certificate.changes.dup

    fetch_and_fill_data_for_doctor if additional_info_absent? || modifying_physician_info?

    return false unless medical_certificate.save

    send_notifications!

    true
  end

  private

  def send_notifications!
    if @changes[:funcionario_corrigir] == [false, true]
      MedicalCertificateMailer.revised_company(medical_certificate).deliver_now
      MedicalCertificateMailer.revised_employers(medical_certificate).deliver_now
    end
  end

  def additional_info_absent?
    medical_certificate.especialidade_medica.blank? ||
      medical_certificate.physician_status_on_cfm.blank?
  end

  def modifying_physician_info?
    return false unless changes
    return false unless medical_certificate.crm_registered?

    changes.include? REGISTRY_NUMBER_FIELDS[:physician]
  end

  def fetch_and_fill_data_for_doctor
    physician_info_updater = MedicalCertificatePhysicianInfoUpdaterService.new(medical_certificate)
    physician_info_updater.call
  end
end
