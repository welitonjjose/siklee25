class FixCfmName < ActiveRecord::Migration[6.0]
  def change
    rename_column :atestados, :crm, :cfm
  end
end
