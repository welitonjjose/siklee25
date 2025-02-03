class AddExamesToAtestados < ActiveRecord::Migration[6.0]
  def change
    add_column :atestados, :exames, :string
    add_column :atestados, :exames_complementares, :string
  end
end
