class AddSubdomainToEmpresas < ActiveRecord::Migration[6.0]
  def change
    add_column :empresas, :subdomain, :string, size: 30
  end
end
