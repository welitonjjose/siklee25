class RemoveAreaDeAtuacaoFromFuncionarios < ActiveRecord::Migration[6.0]
  def change
    remove_column :funcionarios, :area_de_atuacao
  end
end
