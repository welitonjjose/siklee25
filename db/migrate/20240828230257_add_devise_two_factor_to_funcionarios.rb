class AddDeviseTwoFactorToFuncionarios < ActiveRecord::Migration[6.0]
  def change
    add_column :funcionarios, :encrypted_otp_secret, :string
    add_column :funcionarios, :encrypted_otp_secret_iv, :string
    add_column :funcionarios, :encrypted_otp_secret_salt, :string
    add_column :funcionarios, :consumed_timestep, :integer
    add_column :funcionarios, :otp_required_for_login, :boolean
  end
end
