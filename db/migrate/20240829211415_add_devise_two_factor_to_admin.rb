class AddDeviseTwoFactorToAdmin < ActiveRecord::Migration[6.0]
  def change
    add_column :admins, :encrypted_otp_secret, :string
    add_column :admins, :encrypted_otp_secret_iv, :string
    add_column :admins, :encrypted_otp_secret_salt, :string
    add_column :admins, :consumed_timestep, :integer
    add_column :admins, :otp_required_for_login, :boolean
    add_column :admins, :otp_backup_codes, :string, array: true
  end
end
