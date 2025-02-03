class AddCnpjEmployeeToAtestados < ActiveRecord::Migration[6.0]
  def change
    add_column :atestados, :cnpj_employee, :string, null: true, limit: 20
  end
end
