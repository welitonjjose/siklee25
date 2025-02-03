class AddPasswordChangedAtToAdmin < ActiveRecord::Migration[6.0]
  def change
    add_column :admins, :password_changed_at, :datetime
  end
end
