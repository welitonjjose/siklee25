class AddIndexTokenToEmpresas < ActiveRecord::Migration[6.0]
  def up
    # Empresa.find_each do |empresa|
    #   empresa.update_columns(token: SecureRandom.base58(128))
    # end

    # add_index :empresas, :token, unique: true unless index_exists?(:empresas, :token)
  end
end
