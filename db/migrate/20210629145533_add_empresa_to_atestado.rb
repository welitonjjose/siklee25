class AddEmpresaToAtestado < ActiveRecord::Migration[6.0]
  def change
    add_reference :atestados, :empresa, null: false, foreign_key: true
  end
end
