class CreateFuncionarios < ActiveRecord::Migration[6.0]
  def change
    create_table :funcionarios do |t|
      t.string :nome, null: false, default: ''
      t.string :cpf, null: false, default: ''
      t.string :rg, null: false, default: ''
      t.string :data_nascimento, null: false, default: ''
      t.string :sexo, null: false, default: ''
      t.string :celular, null: false, default: ''
      t.string :photo, null: false, default: ''
      t.string :area_de_atuacao, null: false, default: ''
      t.string :lgpd, null: false, default: ''
      t.boolean :funcionario_lgpd, null: false, default: false

      t.timestamps
    end
  end
end
