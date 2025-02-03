class AddFacebookPhotoUrlToFuncionarios < ActiveRecord::Migration[6.0]
  def change
    add_column :funcionarios, :facebook_photo_url, :string
  end
end
