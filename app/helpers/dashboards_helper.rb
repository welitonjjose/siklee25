module DashboardsHelper
  FILTER_PARAMETERS = %i[company_id medical_certificate_type]

  def current_role_for_dashboard
    if employee? && current_user.employer?
      return :employer
    elsif employee? && current_user.manager?
      return :manager
    end

    current_role
  end

  def filtering_dashboard?
    FILTER_PARAMETERS.any? { |key| params[key].present? }
  end

end
