module EmployeesHelper
  FORMATS = {
    cpf: /(\d{3})(\d{3})(\d{3})(\d{2})/,
    phone: /(\d{2})(\d{5})(\d{4})/
  }

  def format_cpf(cpf)
    return '' if cpf.blank?

    cpf.gsub(FORMATS[:cpf], '\1.\2.\3-\4')
  end

  def format_phone(phone)
    return '' if phone.blank?

    phone.gsub(FORMATS[:phone], '(\1) \2-\3')
  end

  def role_by_bound(bound)
    if bound.empregador
      :employer
    elsif bound.gestor
      :manager
    else
      :employee
    end
  end
end
