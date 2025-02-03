class CnpjService
  URL = 'https://receitaws.com.br/v1/cnpj/'

  def self.consultar(cnpj)
    response = HTTParty.get("#{URL}#{cnpj}")

    if response.code == 200
      JSON.parse(response.body)
    else
      {
        status: response.code,
        message: response.body
      }
    end
  end
end