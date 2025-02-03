class CreateVinculos < ActiveRecord::Migration[6.0]
  def change
    create_table :vinculos do |t|
      t.references :empresa, null: false, foreign_key: true
      t.references :funcionario, null: false, foreign_key: true
      t.boolean :empregador, null: false, default: false
      t.string :cargo, null: false, default: ''
      t.boolean :aprovado, null: false, default: false

      t.timestamps
    end
  end
end
