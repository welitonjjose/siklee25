class AddSubscreverToOkays < ActiveRecord::Migration[6.0]
  def change
    add_column :okays, :subscrever, :boolean, default: false
  end
end
