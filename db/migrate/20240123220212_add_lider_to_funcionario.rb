class AddLiderToFuncionario < ActiveRecord::Migration[6.0]
  def change
    add_column :vinculos, :funcionario_lider_id, :integer
  end
end
