module BaseMailer
  SUBJECT_SCOPE = :defaults

  private

  def subject_for(notification, scope: self.class::SUBJECT_SCOPE)
    I18n.t("mailers.subjects.#{scope}.#{notification}")
  end
end
