class AddCnpjToVinculos < ActiveRecord::Migration[6.0]
  def change
    add_column :vinculos, :cnpj_employee, :string
    add_column :vinculos, :squad, :string
  end
end
