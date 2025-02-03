require 'custom_logger'

class ConselhoRegionalOdontologiaApi
  API_KEY = 'SNDtZATciIdGSkBX4mKZJ0QV24MtpfwQ03d2keH6'
  ENDPOINT = 'https://api.infosimples.com/api/v2/consultas/cro/cadastro'

  HTTP_STATUS_OK = 200

  Result = Struct.new(:success?, :data)

  PHYSICIAN_STATUSES = {
    'ATIVO' => :regular,
  }.freeze

  class << self
    def get_doctor_by(cro:, uf:, client: HTTParty, logger: CustomLogger)
      return Result.new(false, {}) if Rails.env.development?

      response = client.post(ENDPOINT, {
        body: {
          token: API_KEY,
          inscricao: cro,
          uf: uf
        }
      })

      if valid_response?(response)
        Result.new(true, result_for(response, cro, uf))
      else
        report("Failed to fetch data for CRO #{cro}-#{uf}", logger: logger)

        Result.new(false, {})
      end
    end

    def physician_status(status)
      PHYSICIAN_STATUSES[status]
    end

    def report(message, logger:)
      logger.report(message)
    end

    private

    def valid_response?(response)
      response.success? && response['code'] == HTTP_STATUS_OK
    end

    def result_for(response, cro, uf)
      data = response.fetch('data', {}).first

      {
        nome: data['nome'],
        cro: cro,
        uf: uf,
        especialidade: data['especialidades'],
        situacao: data['situacao']
      }
    end
  end
end
