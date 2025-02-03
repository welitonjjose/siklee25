class AddCrmToAtestados < ActiveRecord::Migration[6.0]
  def change
    add_column :atestados, :crm, :boolean, default: false
  end
end
