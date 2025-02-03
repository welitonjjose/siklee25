if Rails.env.production?
    raise StandardError.new('Seeds are not supposed to run on production environment')
  end
  
  require 'faker'
  
  # Delete existing records
  [Link, Vinculo, Funcionario, ConsultantTeam, Consultant, Empresa, Atestado].each(&:delete_all)
  
  # Create Empresas
  empresas = [
    { email: 'empresa@empresaum.com', password: '123123', razao_social: 'Empresa Um', cnpj: Faker::Number.number(digits: 14), telefone: '1198765432', endereco: 'Rua tal, 123', celular: '1198761234', estado: 'SP', cidade: 'São Paulo', cep: '30301123' },
    { email: 'empresa@empresadois.com', password: '123123', razao_social: 'Empresa Dois', cnpj: Faker::Number.number(digits: 14), telefone: '1198765432', endereco: 'Rua tal, 123', celular: '1198761234', estado: 'SP', cidade: 'São Paulo', cep: '30301123' },
    { email: 'empres1a@empresatres.com', password: '123123', razao_social: 'Empresa Dois', cnpj: Faker::Number.number(digits: 14), telefone: '1198765432', endereco: 'Rua tal, 123', celular: '1198761234', estado: 'SP', cidade: 'São Paulo', cep: '30301123' }
  ]
  
  empresas.each { |empresa| Empresa.create!(empresa) }
  
  # Create Squads
  squads = [
    { name: 'Squad 1', empresa: Empresa.find_by(email: 'empresa@empresaum.com') },
    { name: 'Squad 2', empresa: Empresa.find_by(email: 'empresa@empresadois.com') },
    { name: 'Squad 3', empresa: Empresa.find_by(email: 'empres1a@empresatres.com') }
  ]
  
  squads.each { |squad| Squad.create!(squad) }
  
  # Create Funcionarios
  3.times do |batch|
    5.times do |i|
      Funcionario.create!(
        email: "func#{batch * 5 + i}@teste.com",
        password: "123123",
        nome: Faker::Name.name,
        cpf: Faker::Number.number(digits: 11),
        rg: Faker::Number.number(digits: 10),
        data_nascimento: "20/10/1963",
        celular: Faker::PhoneNumber.cell_phone,
        sexo: "Masculino",
        funcionario_lgpd: true
      )
    end
  end
  
  # Create Vinculos
  Funcionario.all.each_with_index do |funcionario, index|
    empresa = Empresa.find_by(email: "empresa@empresaum.com")
    squad = Squad.find_by(name: "Squad #{(index / 5) + 1}")
    Vinculo.create!(
      empresa: empresa,
      squad: squad,
      funcionario: funcionario,
      cargo: Faker::Job.title,
      aprovado: false,
      empregador: false
    )
  end
  
  # Create Consultants
  consultants = [
    { email: 'consultant_one@teste.com', password: '123123', razao_social: 'Consultor Um', cnpj: Faker::Number.number(digits: 14), telefone: Faker::PhoneNumber.phone_number, endereco: Faker::Address.full_address, celular: Faker::PhoneNumber.cell_phone, estado: 'SP', cidade: 'São Paulo', cep: '30301123', nome: 'Consultoria Um' },
    { email: 'consultant_two@teste.com', password: '123123', razao_social: 'Consultor Dois', cnpj: Faker::Number.number(digits: 14), telefone: Faker::PhoneNumber.phone_number, endereco: Faker::Address.full_address, celular: Faker::PhoneNumber.cell_phone, estado: 'SP', cidade: 'São Paulo', cep: '30301123', nome: 'Consultoria Dois' }
  ]
  
  consultants.each { |consultant| Consultant.create!(consultant) }
  
  # Create Links
  links = [
    { empresa: Empresa.find_by(email: 'empresa@empresaum.com'), consultant: Consultant.find_by(email: 'consultant_one@teste.com') },
    { empresa: Empresa.find_by(email: 'empres1a@empresatres.com'), consultant: Consultant.find_by(email: 'consultant_one@teste.com') },
    { empresa: Empresa.find_by(email: 'empresa@empresadois.com'), consultant: Consultant.find_by(email: 'consultant_two@teste.com') }
  ]
  
  links.each { |link| Link.create!(link) }
  
  # Create Admin
  Admin.create!(email: "admin@admin.com", password: "123123")