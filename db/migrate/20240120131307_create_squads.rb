class CreateSquads < ActiveRecord::Migration[6.0]
  def change
    create_table :squads do |t|
      t.references :empresa
      t.string     :name, null: false
      t.timestamps
    end

    add_reference :vinculos, :squad, index: true

  end
end
