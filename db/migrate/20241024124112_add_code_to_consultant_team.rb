class AddCodeToConsultantTeam < ActiveRecord::Migration[6.0]
  def change
    add_column :consultant_teams, :code, :string
    add_column :consultant_teams, :code_at, :datetime
    add_column :consultant_teams, :valid_opt_at, :datetime
  end
end
