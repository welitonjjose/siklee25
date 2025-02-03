class AddPasswordResetToFuncionarios < ActiveRecord::Migration[6.0]
  def change
    add_column :funcionarios, :password_reset_token, :string
    add_column :funcionarios, :password_reset_sent_at, :datetime
  end
end
