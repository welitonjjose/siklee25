class EmployeesController < ApplicationController
  include AccountScope

  require_company_manager_role! only: %i[new create],
    third_party_access: false

  layout 'redesign', only: %i[new create]

  def new
    @employee = Funcionario.new
  end

  def create
    creation_service = EmployeeCreationService.new(employee_params, current_user, current_role)

    if creation_service.call
      flash[:notice] = t('.success')

      redirect_to empresas_pages_path
    else
      @employee = creation_service.resource
      render :new
    end
  end

  def employee_params
    employee_params = params
      .require(:funcionario)
      .permit(
        :email, :password, :password_confirmation, :nome, :cpf, :rg, :sexo,
        :data_nascimento, :celular, :funcionario_lgpd, :registro_empresa, :pis, :risco_ocupacional,
        vinculos_attributes: [:cargo, :cnpj_employee, :squad_id, :empresa_id]
      )

    employee_params[:vinculos_attributes] = [employee_params[:vinculos_attributes]]

    employee_params
  end
end
