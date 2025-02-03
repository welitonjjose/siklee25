class ChangeTokenToEmpresas < ActiveRecord::Migration[6.0]
  def up
    remove_index :empresas, :authentication_token
    remove_column :empresas, :authentication_token

    add_column :empresas, :token, :string, null: false, default: ''
  end
end
