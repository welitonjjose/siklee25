class AddCodeToConsultant < ActiveRecord::Migration[6.0]
  def change
    add_column :consultants, :code, :string
    add_column :consultants, :code_at, :datetime
    add_column :consultants, :valid_opt_at, :datetime
  end
end
