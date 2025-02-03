class AddMedicoExaminadorToAtestados < ActiveRecord::Migration[6.0]
  def change
    add_column :atestados, :medico_examinador, :string
  end
end
