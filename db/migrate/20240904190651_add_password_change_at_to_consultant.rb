class AddPasswordChangeAtToConsultant < ActiveRecord::Migration[6.0]
  def change
    add_column :consultants, :password_changed_at, :datetime
  end
end
