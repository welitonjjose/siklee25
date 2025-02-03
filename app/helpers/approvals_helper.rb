module ApprovalsHelper
  FILTER_PARAMETERS = %i[
    company_id status origin
    employee_id
  ]

  def filtering_approvals?
    FILTER_PARAMETERS.any? { |key| params[key].present? }
  end
end
