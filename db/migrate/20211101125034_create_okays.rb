class CreateOkays < ActiveRecord::Migration[6.0]
  def change
    create_table :okays do |t|
      t.text :content, default: ''
      t.string :funcionario, default: ''
      t.string :empresa, default: ''
      t.boolean "okay", default: false
      t.references :funcionario, null: false, foreign_key: true
      t.references :empresa, null: false, foreign_key: true

      t.timestamps
    end
  end
end
