class DropPhotoColumn < ActiveRecord::Migration[6.0]
  def change
    remove_column :funcionarios, :photo
  end
end
