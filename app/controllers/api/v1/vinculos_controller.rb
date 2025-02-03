class Api::V1::VinculosController < Api::V1::BaseController
  def create
    @vinculo = Vinculo.create(vinculo_params)
    respond_with(@vinculo)
  end

  private

  def vinculo_params
    params.fetch(:vinculo, {}).permit(
      :funcionario_id,
      :cargo,
      :cnpj_employee,
      :squad
    ).merge(
      empresa: current_empresa
    )
  end
end
