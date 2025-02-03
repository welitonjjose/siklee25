module MedicalCertificatesFiltersConcern
  extend ActiveSupport::Concern

  def apply_filter_by_status(status, medical_certificates)
    case status
    when 'pending'
      medical_certificates.where(
        '(funcionario_okay = ? OR empresa_okay = ?) AND empresa_subscrever = ?',
        false, false, false
      )
    when 'approved'
      medical_certificates.where(
        'funcionario_okay = ? AND empresa_okay = ? AND empresa_subscrever != ?',
        true, true, true
      )
    when 'annulled'
      medical_certificates.where(empresa_subscrever: true)
    when 'edited'
      medical_certificates.where(
        'funcionario_corrigir = ? AND empresa_okay != ?',
        true, true
      )
    when 'reverted'
      medical_certificates.where(empresa_reverter: true)
    end
  end
end
