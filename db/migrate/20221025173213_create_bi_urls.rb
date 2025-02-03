class CreateBiUrls < ActiveRecord::Migration[6.0]
  def change
    create_table :bi_urls do |t|
      t.string :bi_url, limit: 500
      t.references :admin, null: false, foreign_key: true
      t.timestamps
    end
  end
end
