class CreateCfms < ActiveRecord::Migration[6.0]
  def change
    create_table :cfms do |t|
      t.text :content, default: ''
      t.string :funcionario, default: ''
      t.boolean "cfm", default: false
      t.references :funcionario, null: false, foreign_key: true

      t.timestamps
    end
  end
end
