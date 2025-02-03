class FixAssociationsForConsultantsAndCollaborators < ActiveRecord::Migration[6.0]
  def up
    remove_reference(:links, :consultant_team, foreign_key: true)
    remove_column(:links, :function)

    add_column(:consultant_teams, :function, :string, null: false, default: '')

    create_table(:collaborations) do |t|
      t.belongs_to :consultant, foreign_key: true
      t.belongs_to :collaborator, foreign_key: { to_table: :consultant_teams }

      t.column :status, :integer, default: 0, null: false

      t.timestamps
    end
  end

  def down
    add_reference(:links, :consultant_team, foreign_key: true)

    drop_table(:collaborations)

    remove_column(:consultant_teams, :function)

    add_column(:links, :function, :string, null: false, default: '')
  end
end
