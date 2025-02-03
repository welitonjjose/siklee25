class CodeMailer < ApplicationMailer
  include BaseMailer
  helper MailersHelper

  default from: 'leonardo@siklee.com'
  layout 'mailer'


  def send_code(resource)
    @resource = resource
    mail(to: @resource.email, subject: "Confirmação de Acesso Siklee")
  end
end
