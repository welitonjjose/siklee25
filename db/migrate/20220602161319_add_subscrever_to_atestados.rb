class AddSubscreverToAtestados < ActiveRecord::Migration[6.0]
  def change
    add_column :atestados, :empresa_subscrever, :boolean, default: false
  end
end
