class AddUfMedicoToAtestados < ActiveRecord::Migration[6.0]
  def change
    add_column :atestados, :uf_medico, :string
  end
end
