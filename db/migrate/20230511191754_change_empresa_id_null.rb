class ChangeEmpresaIdNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :links, :empresa_id, true
  end
end
