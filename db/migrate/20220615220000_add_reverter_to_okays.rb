class AddReverterToOkays < ActiveRecord::Migration[6.0]
  def change
    add_column :okays, :reverter, :boolean, default: false
  end
end
