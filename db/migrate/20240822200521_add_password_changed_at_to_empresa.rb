class AddPasswordChangedAtToEmpresa < ActiveRecord::Migration[6.0]
  def change
    add_column :empresas, :password_changed_at, :datetime
  end
end
