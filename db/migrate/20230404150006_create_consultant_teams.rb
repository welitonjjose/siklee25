class CreateConsultantTeams < ActiveRecord::Migration[6.0]
  def change
    create_table :consultant_teams do |t|
      t.string :nome, null: false, default: ''
      t.string :celular, null: false, default: ''

      t.timestamps
    end
  end
end
