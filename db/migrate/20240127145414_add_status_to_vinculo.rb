class AddStatusToVinculo < ActiveRecord::Migration[6.0]
  def change
    add_column :vinculos, :ativo, :boolean, null: false, default: true
  end
end
