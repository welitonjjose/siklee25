class AddDeviseTwoFactorBackupableToFuncionario < ActiveRecord::Migration[6.0]
  def change
    add_column :funcionarios, :otp_backup_codes, :string, array: true
  end
end
