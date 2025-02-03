class AddPhysicianStatusOnCfmToAtestados < ActiveRecord::Migration[6.0]
  def change
    add_column :atestados, :physician_status_on_cfm, :integer, nil: true
    add_column :atestados, :examining_physician_status_on_cfm, :integer, nil: true
  end
end
