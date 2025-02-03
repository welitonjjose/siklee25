class AddRiscoOcupacionalToFuncionarios < ActiveRecord::Migration[6.0]
  def change
    add_column :funcionarios, :risco_ocupacional, :text
  end
end
