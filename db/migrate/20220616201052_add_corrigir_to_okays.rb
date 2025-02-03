class AddCorrigirToOkays < ActiveRecord::Migration[6.0]
  def change
    add_column :okays, :corrigir, :boolean, default: false
  end
end
