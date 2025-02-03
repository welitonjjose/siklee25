class AddFacebookAuthToFuncionario < ActiveRecord::Migration[6.0]
  def change
    add_column :funcionarios, :uid, :string
    add_column :funcionarios, :provider, :string
  end
end
