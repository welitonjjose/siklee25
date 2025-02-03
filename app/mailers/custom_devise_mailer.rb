class CustomDeviseMailer < Devise::Mailer
  include BaseMailer

  default from: 'leonardo@siklee.com'

  layout 'mailer'

  helper MailersHelper

  SUBJECT_SCOPE = :devise
end
