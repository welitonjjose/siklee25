class RemoveFuncionarioIdFromLinks < ActiveRecord::Migration[6.0]
    def change
      remove_column :links, :funcionario_id
    end
  end
  