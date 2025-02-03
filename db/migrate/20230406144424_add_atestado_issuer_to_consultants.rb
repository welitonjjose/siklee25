class AddAtestadoIssuerToConsultants < ActiveRecord::Migration[6.0]
  def change
    add_column :consultants, :atestado_issuer, :boolean, default: false, null: false
  end
end
