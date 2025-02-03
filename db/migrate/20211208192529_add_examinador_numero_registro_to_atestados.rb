class AddExaminadorNumeroRegistroToAtestados < ActiveRecord::Migration[6.0]
  def change
    add_column :atestados, :examinador_numero_registro, :string
  end
end
