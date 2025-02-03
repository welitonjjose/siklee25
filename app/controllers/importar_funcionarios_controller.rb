class ImportarFuncionariosController < ApplicationController
  before_action :authenticate_admin!

  def index; end

  def create
    file_tmp = params[:file]#.tempfile
    filepath = "#{Rails.root}/tmp/funcionarios-#{empresa.id}.xlsx"

    File.open(filepath, 'wb') do |file|
      file.write(file_tmp.read)
    end

    redirect_to importar_funcionarios_path, notice: "Arquivo enviado para fila de processamento!"
  end

end

