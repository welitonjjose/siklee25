class Api::V1::EmpresasController < Api::V1::BaseController
  def create
    @empresa = Empresa.create(empresa_params)
    respond_with(@empresa)
  end

  private

  def empresa_params
    params.fetch(:empresa, {}).permit(
      :razao_social,
      :cnpj,
      :telefone,
      :endereco,
      :celular,
      :estado,
      :cidade,
      :cep,
      :email
    ).merge(
      password: SecureRandom.base58(8)
    )
  end
end
