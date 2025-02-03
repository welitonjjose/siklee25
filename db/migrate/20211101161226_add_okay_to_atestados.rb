class AddOkayToAtestados < ActiveRecord::Migration[6.0]
  def change
    add_column :atestados, :funcionario_okay, :boolean, default: false
    add_column :atestados, :empresa_okay, :boolean, default: false
  end
end
