class AddReverterToAtestados < ActiveRecord::Migration[6.0]
  def change
    add_column :atestados, :empresa_reverter, :boolean, default: false
  end
end
