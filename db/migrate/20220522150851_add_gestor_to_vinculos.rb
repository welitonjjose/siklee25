class AddGestorToVinculos < ActiveRecord::Migration[6.0]
  def change
    add_column :vinculos, :gestor, :boolean, default: false, null: false
  end
end
