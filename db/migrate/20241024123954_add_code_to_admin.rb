class AddCodeToAdmin < ActiveRecord::Migration[6.0]
  def change
    add_column :admins, :code, :string
    add_column :admins, :code_at, :datetime
    add_column :admins, :valid_opt_at, :datetime
  end
end
