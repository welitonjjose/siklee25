class AddCodeToFuncionario < ActiveRecord::Migration[6.0]
  def change
    add_column :funcionarios, :code, :string
    add_column :funcionarios, :code_at, :datetime
    add_column :funcionarios, :valid_opt_at, :datetime
  end
end
