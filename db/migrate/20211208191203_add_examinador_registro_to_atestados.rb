class AddExaminadorRegistroToAtestados < ActiveRecord::Migration[6.0]
  def change
    add_column :atestados, :examinador_registro, :string
  end
end
