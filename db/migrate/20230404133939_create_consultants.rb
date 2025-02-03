class CreateConsultants < ActiveRecord::Migration[6.0]
  def change
    create_table :consultants do |t|
      t.string "razao_social"
      t.string "cnpj"
      t.string "telefone"
      t.string "endereco"
      t.string "celular"
      t.string "estado"
      t.string "cidade"
      t.string "cep"
      t.string "nome"

      t.timestamps
    end
  end
end
