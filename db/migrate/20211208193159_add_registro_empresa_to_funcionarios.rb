class AddRegistroEmpresaToFuncionarios < ActiveRecord::Migration[6.0]
  def change
    add_column :funcionarios, :registro_empresa, :string
    add_column :funcionarios, :pis, :string
  end
end
