class CreateAtestados < ActiveRecord::Migration[6.0]
  def change
    create_table :atestados do |t|
      t.string "nome_do_medico"
      t.string "tipo_de_registro"
      t.string "numero_de_registro"
      t.string "especialidade_medica"
      t.string "instituicao_de_saude"
      t.string "cnpj"
      t.string "endereco"
      t.string "cidade"
      t.string "estado"
      t.string "cep"
      t.string "telefone"
      t.string "nome_funcionario"
      t.string "cpf_funcionario"
      t.string "rg_funcionario"
      t.string "acesso_funcionario"
      t.string "tipo_de_atestado"
      t.date "data_de_emissao"
      t.date "data_de_apresentacao"
      t.text "descricao_do_afastamento"
      t.string "tempo_de_dispensa"
      t.string "cid"
      t.references :funcionario, null: false, foreign_key: true
      t.timestamps
    end
  end
end
