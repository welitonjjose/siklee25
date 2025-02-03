class Api::V1::FuncionariosController < Api::V1::BaseController
  def create
    @funcionario = Funcionario.create(funcionario_params)
    respond_with(@funcionario)
  end

  private

  def funcionario_params
    squad = nil
    if params[:funcionario].present? &&
       params[:funcionario][:vinculo].present?  &&
       params[:funcionario][:vinculo][:squad].present?
      squad = Squad.where(empresa_id: current_empresa.id)
                  .where(name: params[:funcionario][:vinculo][:squad])
                  .first
      squad ||= Squad.create(empresa: current_empresa, name: params[:funcionario][:vinculo][:squad])
    end
    _params = params.fetch(:funcionario, {}).permit(
      :nome,
      :cpf,
      :rg,
      :data_nascimento,
      :sexo,
      :celular,
      :email,
      :registro_empresa,
      :pis,
      :risco_ocupacional,
      {vinculo: %i[cargo cnpj_employee squad]}
    )

    _params.merge!(
      password: SecureRandom.base58(8),
      vinculos_attributes: [
        _params.delete(:vinculo).to_h.merge({empresa: current_empresa, squad: squad})
      ]
    )
  end
end
