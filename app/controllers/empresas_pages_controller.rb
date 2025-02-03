class EmpresasPagesController < ApplicationController
  include AccountScope
  include BondFiltersConcern


  require_company_user! only: %i[
    index toggle_empregador
  ]

  require_consultant_user! only: %i[
    index toggle_empregador
  ]

  require_company_or_employer_role! only: %i[
    index toggle_gestor toggle_empregador
  ]

  require_collaborator_role! only: %i[
    index toggle_gestor toggle_empregador
  ]

  require_company_or_admin! only: %i[
    funcionarios_function funcionarios_form funcionarios_form_update
  ]

  before_action :authenticate_empresa!, except: %i[
    funcionarios_function funcionarios_form funcionarios_form_update toggle_gestor toggle_empregador
  ]

  layout 'redesign'

  FILTERS = {
    roles: %i[employee manager employer],
    user_statuses: %i[active inactive]
  }

  def index
    @vinculos = current_empresa.vinculos.includes(:funcionario)

    @departments = departments_for([current_empresa.id])
    @job_functions = job_functions_for([current_empresa.id])

    @vinculos = @vinculos.global_search(params[:query]) if params[:query].present?

    @vinculos = filter_by_role(@vinculos, params[:role].to_sym) if params[:role].present?

    @vinculos = filter_by_status(@vinculos, params[:user_status].to_sym) if params[:user_status].present?
    @vinculos = filter_by_department(@vinculos, params[:department]) if params[:department].present?
    @vinculos = filter_by_job_function(@vinculos, params[:job_function]) if params[:job_function].present?

    @vinculos = filter_by_employee_leader(@vinculos, params[:funcionario_lider_id]) if params[:funcionario_lider_id].present?

    @vinculos = @vinculos.left_joins(:refatestados)
                             .group(:id)
                             .reorder('COUNT("atestados"."id") DESC')
  end

  def toggle_empregador
    if admin? || consultant? || collaborator? 
      bond = Vinculo.find(params[:id])
    else
      bond = current_user.vinculos.find_by_id(params[:id])
    end
   
    return render_not_found_page unless bond

    message = t('.error')
    message = t('.success') if bond.update(empregador: !!!bond.empregador?)

    if company?
      redirect_to empresas_pages_path, notice: message
    else
      redirect_to funcionarios_pages_path, notice: message
    end
  end

  def toggle_gestor
    destination = empresas_pages_path

    if admin? || consultant? || collaborator?
      bond = Vinculo.find(params[:id])
    elsif company?
      bond = current_user.vinculos.find_by_id(params[:id])
    elsif employee? && current_user.employer?
      destination = funcionarios_pages_path

      employer_bond = current_user.most_recent_bond

      bond = Vinculo.where(empresa_id: employer_bond.empresa_id)
                    .find_by_id(params[:id])
    end

    if consultant? || collaborator?
      destination = funcionarios_pages_path
    end

    return render_not_found_page unless bond

    message = t('.error')

    message = t('.success') if bond.update(gestor: !!!bond.gestor?)

    redirect_to destination, notice: message
  end

  def funcionarios_function
    if admin?
      @company_id = params.fetch('/funcionarios_function', {}).fetch(:company_id, nil)

      if @company_id
        source = Vinculo.where(empresa_id: @company_id)
      else
        source = Vinculo.where(empresa_id: -1)
      end
    else
      source = current_empresa.vinculos
    end

    employee_ids = source.where(empregador: true).ids
    manager_ids = source.where(gestor: true).ids

    @vinculos = Vinculo.where(id: employee_ids.concat(manager_ids))
  end

  def funcionarios_form
    if admin?
      @vinculo = Vinculo.find(params[:id])
    else
      @vinculo = current_user.vinculos.find_by_id(params[:id])
    end

    return render_not_found_page unless @vinculo
  end

  def funcionarios_form_update
    if admin?
      bond = Vinculo.find(params[:id])
    else
      bond = current_user.vinculos.find_by_id(params[:id])
    end

    return render_not_found_page unless bond

    employee = bond.funcionario

    message = t('.error')

    message = t('.success') if employee.update(funcionario_params)

    redirect_to empresas_pages_path, notice: message
  end


  def importar_funcionarios
  end

  def importar_funcionarios_create
    return redirect_to empresas_pages_path if params[:employee].nil?

    xlsx = Roo::Spreadsheet.open(params[:employee][:file].tempfile)

    xlsx.each_with_index do |row, index|
      next if index.zero?
      
      begin
        password = SecureRandom.hex(10)
        funcionario = Funcionario.find_or_create_by(cpf: row[1])
        
        funcionario.update({
          nome: row[0],
          rg: row[2],
          data_nascimento: row[3].strftime('%d/%m/%Y'),
          sexo: row[4],
          celular: row[5],
          email: row[6],
          registro_empresa: row[10],
          pis: row[11],
          risco_ocupacional: row[12],
          password: password,
          password_confirmation: password
        })

        squad = Squad.find_or_create_by(
          name: row[8], 
          empresa: current_empresa 
        )

        vinculo = Vinculo.find_or_create_by(
          empresa_id: current_empresa.id,
          funcionario_id: funcionario.id,
        )
        vinculo.update({
          empregador: false,
          cargo:  row[7],
          squad: squad,
          aprovado: false,
          cnpj_employee:  row[9],
          ativo: (row[13].to_s.downcase == "ativo")? true: false
        })

      rescue
      end
    end

    redirect_to empresas_pages_path, notice: "Processamos o arquivo com sucesso!"
  end

  private

  def empresa_params
    params.require(:empresa).permit(
      :razao_social, :cnpj, :telefone,
      :celular, :email, :endereco,
      :estado, :cidade, :cep, :contato, :cargo
    )
  end

  def funcionario_params
    params.require(:funcionario).permit(
      :nome,
      :registro_empresa, :pis, :risco_ocupacional,
      vinculos_attributes: %i[
        id cargo cnpj_employee squad_id funcionario_lider_id ativo
      ]
    )
  end

  def filter_by_role(bonds, role)
    return bonds if bonds.empty? || !FILTERS[:roles].include?(role)

    case role
    when :employee
      bonds.where(empregador: false, gestor: false)
    when :manager
      bonds.where(empregador: false, gestor: true)
    when :employer
      bonds.where(empregador: true, gestor: false)
    else
      bonds
    end
  end

  def filter_by_status(bonds, status)
    return bonds if bonds.empty? || !FILTERS[:user_statuses].include?(status.to_sym)

    filtered_bonds = bonds.joins('INNER JOIN funcionarios AS func ON vinculos.funcionario_id = func.id')

    case status.to_sym
    when :active
      filtered_bonds.where('vinculos.ativo = true')
    when :inactive
      filtered_bonds.where('vinculos.ativo = false')
    else
      filtered_bonds
    end
  end

end
