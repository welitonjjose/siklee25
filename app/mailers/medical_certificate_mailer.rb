class MedicalCertificateMailer < ApplicationMailer
  include BaseMailer

  helper EmployeesHelper
  helper MailersHelper

  SUBJECT_SCOPE = :medical_certificate

  def annulled(medical_certificate)
    @medical_certificate = medical_certificate
    @employee = medical_certificate.funcionario
    @recipient_role = :employee

    recipient = @employee.email

    mail(to: recipient, subject: subject_for(__method__))
  end

  def approved(medical_certificate)
    @medical_certificate = medical_certificate
    @employee = medical_certificate.funcionario
    @recipient_role = :employee

    recipient = @employee.email

    mail(to: recipient, subject: subject_for(__method__))
  end

  def created(medical_certificate)
    @medical_certificate = medical_certificate
    @employee = medical_certificate.funcionario
    @recipient_role = :employee

    recipient = @employee.email

    mail(to: recipient, subject: subject_for(__method__))
  end

  def reverted(medical_certificate)
    @medical_certificate = medical_certificate
    @employee = medical_certificate.funcionario
    @recipient_role = :employee

    recipient = @employee.email

    mail(to: recipient, subject: subject_for(__method__))
  end

  def revised_company(medical_certificate)
    @medical_certificate = medical_certificate
    @employee = medical_certificate.funcionario

    @recipient_role = :company
    recipient = company_email_for(medical_certificate)

    mail(
      to: recipient,
      subject: subject_for(:revised),
      template_name: :revised
    )
  end

  def revised_employers(medical_certificate)
    @medical_certificate = medical_certificate
    @employee = medical_certificate.funcionario

    @recipient_role = :employee
    recipients = employer_emails_for(medical_certificate.empresa_id)

    return if recipients.empty?

    mail(
      bcc: recipients,
      subject: subject_for(:revised),
      template_name: :revised
    )
  end

  def waiting_approval_company(medical_certificate)
    @medical_certificate = medical_certificate
    @employee = medical_certificate.funcionario

    @recipient_role = :company
    recipient = company_email_for(medical_certificate)

    mail(
      to: recipient,
      subject: subject_for(:waiting_approval),
      template_name: :waiting_approval
    )
  end

  def waiting_approval_employers(medical_certificate)
    @medical_certificate = medical_certificate
    @employee = medical_certificate.funcionario

    @recipient_role = :employee
    recipients = employer_emails_for(medical_certificate.empresa_id)

    return if recipients.empty?

    mail(
      bcc: recipients,
      subject: subject_for(:waiting_approval),
      template_name: :waiting_approval
    )
  end

  private

  def company_email_for(medical_certificate)
    company_id = medical_certificate.empresa_id

    Empresa.find(company_id).email
  end

  def employer_emails_for(company_id)
    Vinculo.where(empresa_id: company_id, empregador: true).
      includes(:funcionario).
      pluck('funcionarios.email')
  end
end
