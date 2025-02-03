require 'savon'
require 'custom_logger'

class ConselhoFederalMedicinaApi
  WSDL_URL = 'https://ws.cfm.org.br:8080/WebServiceConsultaMedicos/ServicoConsultaMedicos?wsdl'

  ENDPOINTS = {
    search: :consultar
  }.freeze

  VALID_FORMATS = {
    search: :dados_medico
  }.freeze

  API_KEY = 'SWTSLOIS'

  PHYSICIAN_STATUSES = {
    'A' => :regular,
    'B' => :permanently_partial_suspended,
    'C' => :anulled,
    'E' => :inoperative,
    'F' => :dead,
    'G' => :not_regulated_for_region,
    'I' => :precautionary_interdiction,
    'J' => :partial_suspended_by_court_order,
    'L' => :canceled,
    'M' => :temporary_full_suspended,
    'N' => :partial_precautionary_interdiction,
    'O' => :suspended_by_court_order,
    'P' => :retired,
    'R' => :temporary_suspended,
    'S' => :fully_suspended,
    'T' => :transferred,
    'X' => :partial_suspended
  }.freeze

  Result = Struct.new(:success?, :data)

  class << self
    def get_doctor_by(crm:, uf:, client: Savon.client(wsdl: WSDL_URL), logger: CustomLogger)
      return Result.new(false, {}) if Rails.env.development?

      endpoint = :search
      wsdl_endpoint = ENDPOINTS[endpoint]

      result = client.call(wsdl_endpoint, message: {
        crm: crm,
        uf: uf,
        chave: API_KEY
      })

      if valid_response?(result.body, endpoint: endpoint)
        Result.new(true, result_for(result.body, endpoint: endpoint))
      else
        report("Failed to fetch data for CRM #{crm}-#{uf}", logger: logger)

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

    def valid_response?(body, endpoint:)
      wsdl_endpoint_response = ENDPOINTS[endpoint]
      response_key = "#{wsdl_endpoint_response}_response".to_sym

      return false unless body.include? response_key

      body[response_key].include? VALID_FORMATS[endpoint]
    end

    def result_for(body, endpoint:)
      wsdl_endpoint_response = ENDPOINTS[endpoint]
      response_key = "#{wsdl_endpoint_response}_response".to_sym

      body[response_key][VALID_FORMATS[endpoint]]
    end
  end
end
