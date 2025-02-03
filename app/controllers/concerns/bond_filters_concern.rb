module BondFiltersConcern
  extend ActiveSupport::Concern

  def departments_for(company_ids)
    Squad.select('id, name').where(empresa_id: company_ids)
  end

  def job_functions_for(company_ids)
    Vinculo.where(empresa_id: company_ids)
           .pluck(:cargo)
           .uniq
  end

  def filter_by_department(bonds, department)
    return bonds if bonds.empty?

    bonds.where(squad: department)
  end

  def filter_by_job_function(bonds, job_function)
    return bonds if bonds.empty?

    bonds.where(cargo: job_function)
  end

  def filter_by_employee_leader(bonds, employee_leader)
    return bonds if bonds.empty?

    bonds.where(funcionario_lider_id: employee_leader)
  end
end
