class AddDeviseTwoFactorToEmpresa < ActiveRecord::Migration[6.0]
  def change
    add_column :empresas, :encrypted_otp_secret, :string
    add_column :empresas, :encrypted_otp_secret_iv, :string
    add_column :empresas, :encrypted_otp_secret_salt, :string
    add_column :empresas, :consumed_timestep, :integer
    add_column :empresas, :otp_required_for_login, :boolean
    add_column :empresas, :otp_backup_codes, :string, array: true
  end
end
