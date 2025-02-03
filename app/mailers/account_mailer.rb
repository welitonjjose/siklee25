class AccountMailer < ApplicationMailer
  include BaseMailer

  helper MailersHelper

  SUBJECT_SCOPE = :account

  def welcome(user, role:, generated_password:)
    @user = user
    @role = t(".roles.#{role}")
    @generated_password = generated_password

    mail(to: user.email, subject: subject_for(__method__))
  end
end
