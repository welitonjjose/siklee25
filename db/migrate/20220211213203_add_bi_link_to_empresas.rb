class AddBiLinkToEmpresas < ActiveRecord::Migration[6.0]
  def change
    add_column :empresas, :bi_url, :string, limit: 500
  end
end
