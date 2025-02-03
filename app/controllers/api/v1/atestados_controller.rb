class Api::V1::AtestadosController < Api::V1::BaseController
  def index
    if params[:query].present?
      @atestados = current_empresa.atestados.global_search(params[:query])
    else
      @atestados = current_empresa.atestados
    end

    @atestados.each do |atestado|
      atestado['tempo_de_dispensa'] = atestado.tempo_de_dispensa_em_horas
    end

    render json: @atestados
  end

  def show
    @atestado = current_empresa.atestados.find(params[:id])

    atestado_json = @atestado.as_json
    atestado_json['tempo_de_dispensa'] = @atestado.tempo_de_dispensa_em_horas

    render json: atestado_json
  end
end
