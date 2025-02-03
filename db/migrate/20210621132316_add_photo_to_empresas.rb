class AddPhotoToEmpresas < ActiveRecord::Migration[6.0]
  def change
    add_column :empresas, :empresa_photo, :string
  end
end
