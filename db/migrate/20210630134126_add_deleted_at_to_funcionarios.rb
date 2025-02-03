class AddDeletedAtToFuncionarios < ActiveRecord::Migration[6.0]
  def change
    add_column :funcionarios, :deleted_at, :datetime
  end
end
