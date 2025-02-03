class AddPasswordChangedAtToFuncionario < ActiveRecord::Migration[6.0]
  def change
    add_column :funcionarios, :password_changed_at, :datetime
  end
end
