json.extract! funcionario, :id, :nome, :cpf, :rg, :data_nascimento, :sexo, :email, :user_id, :created_at, :updated_at
json.url funcionario_url(funcionario, format: :json)
