class RemoveEmpresaAceitoFromLinks < ActiveRecord::Migration[6.0]
  def up
    remove_column :links, :empresa_aceito
  end

  def down
    add_column :links, :empresa_aceito, :boolean, null: false, default: false
  end
end
