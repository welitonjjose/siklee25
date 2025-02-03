class CfmsController < ApplicationController

  def new
    @cfm = Cfm.new
  end
  
  def create
    # @funcionario = Funcionario.find(params[:id])
    @cfm = Cfm.new
    @cfm.funcionario = current_funcionario
    if @cfm.save
      redirect_to atestados_path
    else
      render :new
    end
  end

  private

  def cfm_params
    params.require(:cfm)
  end

end
