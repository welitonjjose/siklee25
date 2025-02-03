class AddDeviseTwoFactorConsultant < ActiveRecord::Migration[6.0]
  def change
    add_column :consultants, :encrypted_otp_secret, :string
    add_column :consultants, :encrypted_otp_secret_iv, :string
    add_column :consultants, :encrypted_otp_secret_salt, :string
    add_column :consultants, :consumed_timestep, :integer
    add_column :consultants, :otp_required_for_login, :boolean
    add_column :consultants, :otp_backup_codes, :string, array: true
  end
end
