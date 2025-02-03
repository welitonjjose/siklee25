class CreateLgpds < ActiveRecord::Migration[6.0]
  def change
    create_table :lgpds do |t|
      t.text :content, default: ''
      t.string :funcionario, default: ''
      t.boolean "lgpd", default: false
      t.references :funcionario, null: false, foreign_key: true
      t.timestamps
    end
  end
end
