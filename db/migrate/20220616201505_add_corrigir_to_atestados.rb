class AddCorrigirToAtestados < ActiveRecord::Migration[6.0]
  def change
    add_column :atestados, :funcionario_corrigir, :boolean, default: false
  end
end
