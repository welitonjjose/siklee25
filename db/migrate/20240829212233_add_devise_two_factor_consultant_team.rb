class AddDeviseTwoFactorConsultantTeam < ActiveRecord::Migration[6.0]
  def change
    add_column :consultant_teams, :encrypted_otp_secret, :string
    add_column :consultant_teams, :encrypted_otp_secret_iv, :string
    add_column :consultant_teams, :encrypted_otp_secret_salt, :string
    add_column :consultant_teams, :consumed_timestep, :integer
    add_column :consultant_teams, :otp_required_for_login, :boolean
    add_column :consultant_teams, :otp_backup_codes, :string, array: true
  end
end
