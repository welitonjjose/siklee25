class FuncionariosPagesController < ApplicationController
  include AccountScope
  include BondFiltersConcern

  require_any_except! roles: %i[company], only: %i[index funcionarios_empresa]
  require_any_except! roles: %i[company], only: %i[vinculos_form vinculos_form_update]
  require_admin! only: %i[destroy_funcionario]
  require_employee! only: %i[show_lgpd update_lgpd]

  layout 'redesign', only: %i[index show_lgpd vinculos_form vinculos_form_update importar_funcionarios]

  FILTERS = {
    roles: %i[employee manager employer],
    user_statuses: %i[active inactive]
  }

  def index
    if admin?
      @vinculos = Vinculo.all
      @empresas = Empresa.all

      authorized_company_ids = @empresas.ids
    elsif employee? && current_user.employer?
      authorized_company_ids = Funcionario.employer_company_ids(current_user)

      @vinculos = Vinculo.where(empresa_id: authorized_company_ids)
    elsif consultant?
      authorized_company_ids = current_consultant.authorized_company_ids

      @empresas = Empresa.where(id: authorized_company_ids)
    elsif collaborator?
      authorized_company_ids = current_consultant_team.authorized_company_ids

      @empresas = Empresa.where(id: authorized_company_ids)
    else
      redirect_to root_path
    end

    @departments = departments_for(authorized_company_ids)

    if params[:company_id].present?
      @departments = departments_for(params[:company_id])
    end
    @job_functions = job_functions_for(authorized_company_ids)
  end

  def funcionarios_empresa
    if admin?
      @vinculos = Vinculo.all
    elsif consultant? || collaborator?
      authorized_company_ids = current_user.authorized_company_ids

      @vinculos = Vinculo.where(empresa_id: authorized_company_ids)

      params[:empresa_id] = nil unless authorized_company_ids.include? params[:empresa_id].to_i
    elsif employee? && current_user.employer?
      bond = current_user.most_recent_bond

      @vinculos = Vinculo.where(empresa_id: bond.empresa_id)
    else
      return render_not_found_page
    end

    @vinculos = @vinculos.includes(:funcionario)

    @vinculos = @vinculos.where(empresa_id: params[:empresa_id]) if params[:empresa_id].present?

    @vinculos = @vinculos.global_search(params[:query]) if params[:query].present?

    @vinculos = filter_by_role(@vinculos, params[:role].to_sym) if params[:role].present?

    @vinculos = filter_by_status(@vinculos, params[:user_status].to_sym) if params[:user_status].present?

    @vinculos = filter_by_department(@vinculos, params[:department]) if params[:department].present?
    @vinculos = filter_by_job_function(@vinculos, params[:job_function]) if params[:job_function].present?

    @vinculos = filter_by_employee_leader(@vinculos, params[:funcionario_lider_id]) if params[:funcionario_lider_id].present?

    @vinculos = @vinculos.left_joins(:refatestados)
                         .group(:id)
                         .reorder('COUNT("atestados"."id") DESC')


    respond_to do |format|
      format.html { render layout: false }
      format.json { render json: { funcionarios: @funcionarios } }
    end
  end

  def vinculos_form
    return render_not_found_page if employee? && !current_user.employer?

    bond_scope = Vinculo.where(funcionario_id: params[:id])

    if consultant? || collaborator?
      authorized_company_ids = current_user.authorized_company_ids

      bond_scope = bond_scope.where(empresa_id: authorized_company_ids)
    elsif employee? && current_user.employer?
      company_id = current_user.most_recent_bond.empresa_id
      bond_scope = bond_scope.where(empresa_id: company_id)
    end

    if bond_scope.exists?
      @funcionario = bond_scope.first.funcionario
    else
      render_not_found_page
    end
  end

  def vinculos_form_update
    return render_not_found_page if employee? && !current_user.employer?

    bond_scope = Vinculo.where(funcionario_id: params[:id])

    if consultant? || collaborator?
      authorized_company_ids = current_user.authorized_company_ids

      bond_scope = bond_scope.where(empresa_id: authorized_company_ids)
    elsif employee? && current_user.employer?
      company_id = current_user.most_recent_bond.empresa_id
      bond_scope = bond_scope.where(empresa_id: company_id)
    end

    if bond_scope.exists?
      employee = bond_scope.first.funcionario

      if employee.update!(funcionario_params)
        redirect_to funcionarios_pages_path, notice: 'Funcionário(a) atualizado com sucesso!'
      end
    else
      render_not_found_page
    end
  end

  def show_lgpd; end

  def update_lgpd
    current_user.update!(
      funcionario_lgpd: true
    )

    redirect_to new_atestado_path
  end

  def destroy_funcionario
    employee = Funcionario.find_by_id(params[:id])

    message = t('.error')

    message = t('.success') if employee && employee.destroy(:hard)

    redirect_to funcionarios_pages_path, notice: message
  end

  def desativar_vinculo
    redirect_to root_path unless employee?

    employee = Funcionario.find(current_user.id)
    current_vinculo = employee.most_recent_bond
    current_vinculo.ativo = false
    current_vinculo.empregador = false
    current_vinculo.gestor = false
    current_vinculo.save

    redirect_to root_path
  end

  def importar_funcionarios
    set_empresa
  end

  def importar_funcionarios_create
    return redirect_to funcionarios_pages_path, notice: "Favor Selecione um arquivo CSV!" if params[:employee][:file].nil?
    empresa_id = params[:employee][:empresa_id].nil? ?  current_user.empresa.id : params[:employee][:empresa_id]

    xlsx = Roo::Spreadsheet.open(params[:employee][:file].tempfile)
    xlsx.each_with_index do |row, index|
      next if index.zero?

      begin
        funcionario = Funcionario.find_or_create_by(cpf: row[1])
        password = SecureRandom.hex(10)
        
        funcionario.update!({
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
          empresa: Empresa.find(empresa_id)
        )

        vinculo = Vinculo.find_or_create_by(
          empresa_id: empresa_id,
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

    return redirect_to funcionarios_pages_path, notice: "Processamos o arquivo com sucesso!" if consultant? || collaborator?
    redirect_to empresas_pages_path, notice: "Processamos o arquivo com sucesso!"
  end

  private

  def funcionario_params
    params.require(:funcionario).permit(
      :cargo, :registro_empresa,
      :pis, :risco_ocupacional,
      :nome,
      vinculos_attributes: %i[
        ativo
        squad_id cargo
        cnpj_employee
        id
        funcionario_lider_id
        cargo
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

  def set_empresa
    if admin?
      @vinculos = Vinculo.all
      @empresas = Empresa.all

      authorized_company_ids = @empresas.ids
    elsif employee? && current_user.employer?
      authorized_company_ids = Funcionario.employer_company_ids(current_user)

      @vinculos = Vinculo.where(empresa_id: authorized_company_ids)
    elsif consultant?
      authorized_company_ids = current_consultant.authorized_company_ids

      @empresas = Empresa.where(id: authorized_company_ids)
    elsif collaborator?
      authorized_company_ids = current_consultant_team.authorized_company_ids

      @empresas = Empresa.where(id: authorized_company_ids)
    end
  end

end
