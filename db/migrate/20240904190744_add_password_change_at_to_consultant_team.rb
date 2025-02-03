class AddPasswordChangeAtToConsultantTeam < ActiveRecord::Migration[6.0]
  def change
    add_column :consultant_teams, :password_changed_at, :datetime
  end
end
