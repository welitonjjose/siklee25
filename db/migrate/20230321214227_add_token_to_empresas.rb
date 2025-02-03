class AddTokenToEmpresas < ActiveRecord::Migration[6.0]
  def change
    add_column :empresas, :authentication_token, :string, limit: 30
    add_index :empresas, :authentication_token, unique: true
  end
end
