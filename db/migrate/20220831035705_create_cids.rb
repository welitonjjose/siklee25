class CreateCids < ActiveRecord::Migration[6.0]
  def change
    create_table :cids do |t|
      t.string :code, null: false, index: { unique: true, name: 'unique_cid_codes' }, limit: 100
      t.string :description, null: false, limit: 255

      t.timestamps
    end
  end
end
