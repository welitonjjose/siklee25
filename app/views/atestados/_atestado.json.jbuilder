attribute_names = %i[
  id
  nome_do_medico
  tipo_de_registro
  numero_de_registro
  especialidade_medica
  instituicao_de_saude
  cnpj
  endereco
  cidade
  estado
  cep
  telefone
  nome_funcionario
  cpf_funcionario
  rg_funcionario
  acesso_funcionario
  tipo_de_atestado
  data_de_emissao
  data_de_apresentacao
  descricao_do_afastamento
  tempo_de_dispensa
  cid
  funcionario_id
  created_at
  updated_at
  cfm
  empresa_id
  funcionario_okay
  empresa_okay
  medico_examinador
  examinador_registro
  examinador_numero_registro
  uf_medico
  uf_examinador
  exames
  exames_complementares
  origem
  empresa_subscrever
  empresa_reverter
  funcionario_corrigir
  physician_status_on_cfm
  examining_physician_status_on_cfm
]

json.extract! atestado, *attribute_names
json.url atestado_url(atestado, format: :json)
