class CreateLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :links do |t|
      t.references :consultant, null: false, foreign_key: true
      t.references :consultant_team, null: false, foreign_key: true
      t.references :funcionario, null: false, foreign_key: true
      t.references :empresa, null: false, foreign_key: true
      t.string :function, null: false, default: ''
      t.boolean :issuer, null: false, default: false
      t.boolean :aprovado, null: false, default: false
      t.boolean :empresa_aceito, null: false, default: false

      t.timestamps
    end
  end
end
