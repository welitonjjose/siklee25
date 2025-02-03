class AddCodeToEmpreasa < ActiveRecord::Migration[6.0]
  def change
    add_column :empresas, :code, :string
    add_column :empresas, :code_at, :datetime
    add_column :empresas, :valid_opt_at, :datetime
  end
end
