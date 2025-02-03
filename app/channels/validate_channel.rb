class ValidateChannel < ApplicationCable::Channel
  def subscribed
    stream_from "validate"
  end

  def receive(data)
  end

  def send_message data
    empresa = Empresa.first

    if  ['empresa', 'gestor', ].include?(data['data']['origem'])
      funcionario = Funcionario.find_by(id: data['data']['funcionario_id'])
    else
      funcionario = empresa.funcionarios.first
    end

    photos = data['data']['photos']

    data['data'].delete('photos')
    data['data'].delete('uuid')

    obj = data['data']
    obj['empresa'] = empresa
    obj['nome_funcionario'] = funcionario&.nome

    atestado = Atestado.new obj

    if photos
      filename = "attachement"
      file = Tempfile.new(filename)
      file.binmode
      file.write(filename)
      file.rewind
      atestado.photos.attach(io: file, filename: filename)
    end

    atestado.valid?
    error = atestado.errors[data['field'].to_sym]

    err_count = []
    verror = []

    atestado.errors.messages.each do |err|
      if err[1][0] != nil
        err_count << err[1][0]
        verror << err
      end
    end

    ability_btn = err_count.count < 1

    ActionCable.server.broadcast "validate", {
      error: error,
      ability_btn: ability_btn,
      data_errors: atestado.errors,
      field: data['field'],
      value: data['data'][data['field']]
    }
  end
end