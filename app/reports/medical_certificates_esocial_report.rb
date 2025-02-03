class MedicalCertificatesEsocialReport
  DEFAULT_ENCODING = 'ISO-8859-1'
  SCHEMA_URL = {
    s2230: 'https://www.esocial.gov.br/schema/evt/evtAfastTemp/v02_05_00',
    s2220: 'https://www.esocial.gov.br/schema/evt/evtMonit/v02_05_00',
  }

  XML_BUILDER = Nokogiri::XML::Builder

  PHYSICIAN_REGISTRY_FORMAT = /^(?<number>\d{1,6})-(?<region>[A-Z]+)$/

  ABSENCE_REASONS = {
    'Acidente de Trabalho' => '01',
    'Doença' => '03',
    'Acidente de Trânsito' => '03',
    'Licença Maternidade' => '17'
  }

  MEDICAL_EXAMINATION_TYPES = {
    'Admissional' => '0',
    'Demissional' => '9',
    'Periódico' => '1',
    'Retorno ao Trabalho' => '2',
    'Mudança de Função' => '3'
  }

  ABSENCE_DURATION_IGNORE_LIST = [nil, '', 'Não aplicável']

  REPORT_DEFAULTS = {
    examination_result_codes: {
      okay: '1'
    },
    examination_codes: {
      default: '0295'
    },
    appropriate_description: 'Funcionário-Apto',
    aso_results: {
      appropriate: '1',
      inapt: '2'
    },
    process_type: {
      administrative: '1',
      legal: '2',
      employee_registry: '3'
    },
    rectification_sources: {
      by_employee: '1',
      administrative_review: '2',
      legal_determination: '3'
    },
    reasons: {
      same: 'S',
      different: 'N'
    },
    rectifying: {
      original: 1,
      rectifying: 2
    },
    environment_identification: {
      production: 1,
      restrict_production: 2,
      validation: 7,
      test: 8,
      development: 9
    },
    app_source: {
      employer: 1
    },
    schema_version: '2_5_00',
    employer_info: {
      company: 1
    }
  }

  IDENTIFIER_FORMATTER = {
    prefix: 'ID',
    initial_sequence: '00001',
    employer: {
      company: '1',
      person: '2'
    },
    company: {
      special_characters: /\.|-|\//,
      characters_limit: 14,
      padstr: '0'
    },
    date_format: '%Y-%m-%d',
    timestamp_format: '%Y%m%d%H%M%S'
  }

  class << self
    def xml(medical_certificates, type: :default)
      builder = case type
                when :default
                  builder_for_default(medical_certificates)
                when :aso
                  builder_for_aso(medical_certificates)
                end

      builder.to_xml
    end

    private

    def builder_for_default(medical_certificates)
      XML_BUILDER.new(encoding: DEFAULT_ENCODING) do |xml|
        xml.eSocial(xmlns: SCHEMA_URL[:s2230]) {
          medical_certificates.each do |medical_certificate|
            employee = medical_certificate.funcionario

            xml.evtAfastTemp(id: format_identifier(medical_certificate)) {
              xml.ideEvento {
                xml.indRetif(rectifying_value_for(medical_certificate))
                xml.tpAmb(environment)
                xml.procEmi(REPORT_DEFAULTS.dig(:app_source, :employer))
                xml.verProc(REPORT_DEFAULTS[:schema_version])
              }

              xml.ideEmpregador {
                xml.tpInsc(REPORT_DEFAULTS.dig(:employer_info, :company))
                xml.nrInsc(employer_identifier_for(medical_certificate))
              }

              xml.ideVinculo {
                xml.cpfTrab(format_employee_identifier(medical_certificate.cpf_funcionario))
                xml.matricula(format_employee_registration(employee))
              }

              absence_reason = format_absence_reason(medical_certificate.descricao_do_afastamento)

              xml.infoAfastamento {
                xml.iniAfastamento {
                  xml.dtIniAfast format_date(medical_certificate.data_de_emissao)

                  xml.codMotAfast absence_reason
                  xml.infoMesmoMtv REPORT_DEFAULTS.dig(:reasons, :different)
                }

                xml.infoRetif {
                  xml.origRetif REPORT_DEFAULTS.dig(:rectification_sources, :by_employee)

                  if sick_or_transit_accident?(absence_reason)
                    xml.tpProc REPORT_DEFAULTS.dig(:process_type, :employee_registry)
                    xml.nrProc employee.pis
                  end
                }

                xml.fimAfastamento {
                  xml.dtTermAfast calculate_return_from_absence(medical_certificate)
                }
              }
            }
          end
        }
      end
    end

    def builder_for_aso(medical_certificates)
      XML_BUILDER.new(encoding: DEFAULT_ENCODING) do |xml|
        xml.eSocial(xmlns: SCHEMA_URL[:s2220]) {
          medical_certificates.each do |medical_certificate|
            employee = medical_certificate.funcionario

            xml.evtMonit(id: format_identifier(medical_certificate)) {
              xml.ideEvento {
                xml.indRetif(rectifying_value_for(medical_certificate))
                xml.tpAmb(environment)
                xml.procEmi(REPORT_DEFAULTS.dig(:app_source, :employer))
                xml.verProc(REPORT_DEFAULTS[:schema_version])
              }

              xml.ideEmpregador {
                xml.tpInsc(REPORT_DEFAULTS.dig(:employer_info, :company))
                xml.nrInsc(employer_identifier_for(medical_certificate))
              }

              xml.ideVinculo {
                xml.cpfTrab(format_employee_identifier(medical_certificate.cpf_funcionario))
                xml.matricula(format_employee_registration(employee))
              }

              xml.exMedOcup {
                xml.tpExameOcup(MEDICAL_EXAMINATION_TYPES[medical_certificate.exames])

                xml.aso {
                  xml.dtAso format_date(medical_certificate.data_de_emissao)
                  xml.resAso format_examination_result(medical_certificate.cid)

                  xml.exame {
                    xml.dtExm format_date(medical_certificate.data_de_emissao)
                    xml.procRealizado REPORT_DEFAULTS.dig(:examination_codes, :default)
                    xml.indResult REPORT_DEFAULTS.dig(:examination_result_codes, :okay)
                  }

                  xml.medico {
                    xml.nmMed medical_certificate.medico_examinador
                    xml.nrCRM format_physician_registry_number(medical_certificate.examinador_numero_registro)
                    xml.ufCRM format_physician_registry_region(medical_certificate.examinador_numero_registro)
                  }
                }

                xml.respMonit {
                  xml.nmResp medical_certificate.nome_do_medico
                  xml.nrCRM format_physician_registry_number(medical_certificate.numero_de_registro)
                  xml.ufCRM format_physician_registry_region(medical_certificate.numero_de_registro)
                }
              }
            }
          end
        }
      end
    end

    # Private: Formats identifier by given eSocial documentation:
    #
    # A identificação única do evento (Id) é composta por 36 caracteres, conforme o que segue:
    #
    #   ID - Texto Fixo "ID";
    #   T - Tipo de Inscrição do Empregador (1 - CNPJ; 2 - CPF);
    #
    #   QQQQQ - Número sequencial da chave. Incrementar somente quando ocorrer geração
    #     de eventos na mesma data/hora, completando com zeros à esquerda.
    #
    # OBS.: No caso de pessoas jurídicas, o CNPJ informado deverá conter 8 ou 14 posições
    #   de acordo com o enquadramento do contribuinte para preenchimento do campo
    #   {ideEmpregador/nrInsc} do evento S-1000, completando-se com zeros à direita, se necessário.
    #
    # Examples:
    #
    # - ID1124630001512022102117500100001
    #
    # Base format: IDTNNNNNNNNNNNNNNAAAAMMDDHHMMSSQQQQQ
    #
    # Returns a String
    def format_identifier(medical_certificate)
      identifier = "#{IDENTIFIER_FORMATTER[:prefix]}"

      identifier.concat IDENTIFIER_FORMATTER.dig(:employer, :company)
      identifier.concat employer_identifier_for(medical_certificate)
      identifier.concat format_timestamp(medical_certificate.data_de_emissao)
      identifier.concat IDENTIFIER_FORMATTER[:initial_sequence]

      identifier
    end

    # Private: Formats company identifier:
    #
    #   NNNNNNNNNNNNNN - Número do CNPJ ou CPF do empregador - Completar com zeros à direita.
    #     No caso de pessoas jurídicas, o CNPJ informado deve conter 8 ou 14 posições de
    #     acordo com o enquadramento do contribuinte para preenchimento do campo
    #     {ideEmpregador/nrInsc} do evento S-1000, completando-se com
    #     zeros à direita, se necessário.
    #
    #      	Informar o número de inscrição do contribuinte de acordo com o tipo de
    #      	  inscrição indicado no campo tpInsc.
    #
    #       Validação: Se tpInsc for igual a [1], deve ser um número de CNPJ válido.
    #         Neste caso, deve ser informada apenas a raiz/base (8 posições),
    #         exceto se a natureza jurídica do declarante for igual a 101-5,
    #         104-0, 107-4, 116-3 ou 134-1, situação em que o campo deve ser
    #         preenchido com o CNPJ completo (14 posições).
    #
    #       Se tpInsc for igual a [2], deve ser um CPF válido.
    #
    # Returns a String
    def employer_identifier_for(medical_certificate)
      cnpj = medical_certificate.empresa.cnpj

      if medical_certificate.cnpj_employee.present?
        cnpj = medical_certificate.cnpj_employee
      end

      format_company_identifier(cnpj)
    end

    def format_company_identifier(cnpj)
      company_options = IDENTIFIER_FORMATTER[:company]

      cnpj
        .gsub(company_options[:special_characters], '')
        .ljust(company_options[:characters_limit],
               company_options[:padstr])
    end

    def format_employee_identifier(identifier)
      return '' unless identifier

      identifier.gsub(IDENTIFIER_FORMATTER.dig(:company, :special_characters), '')
    end

    # Private: Formats timestamp for given format
    #
    #   AAAAMMDD - Ano, mês e dia da geração do evento;
    #   HHMMSS - Hora, minuto e segundo da geração do evento;
    #
    # Returns a String
    def format_timestamp(timestamp)
      timestamp.strftime(IDENTIFIER_FORMATTER[:timestamp_format])
    end

    # Private: Formats date for given format
    #
    #   AAAA-MM-DD - Ano, mês e dia da geração do evento;
    #
    # Returns a String
    def format_date(date)
      date.strftime(IDENTIFIER_FORMATTER[:date_format])
    end

    def rectifying_value_for(medical_certificate)
      REPORT_DEFAULTS.dig(:rectifying, :original)
    end

    def environment
      REPORT_DEFAULTS.dig(:environment_identification, Rails.env.to_sym)
    end

    # Private: Formats employee registration
    #
    #   Matrícula atribuída ao trabalhador pela empresa ou, no caso de
    #     servidor público, a matrícula constante no Sistema de
    #     Administração de Recursos Humanos do órgão.
    #
    #   Validação: Deve corresponder à matrícula informada pelo empregador
    #     no evento S-2200 ou S-2300 do respectivo contrato.
    #
    #     Não preencher no caso de Trabalhador Sem Vínculo de Emprego/Estatutário
    #     - TSVE sem informação de matrícula no evento S-2300.
    #
    # Returns a String
    def format_employee_registration(employee)
      employee.try(:registro_empresa)
    end

    # Private: Formats absence reason by given table
    #
    # Returns a String
    def format_absence_reason(reason)
      ABSENCE_REASONS[reason]
    end

    # Private: Determines if absence reason caused
    # by transit accident or sickness
    #
    # Returns a Boolean
    def sick_or_transit_accident?(reason)
      [
        ABSENCE_REASONS['Doença'],
        ABSENCE_REASONS['Acidente de Trânsito']
      ].include? reason
    end

    # Private: Calculates the date that employee will
    # return by given absence duration and the date
    # the absence started.
    #
    # Returns a Date
    def calculate_return_from_absence(medical_certificate)
      absence_duration = medical_certificate.tempo_de_dispensa

      if ABSENCE_DURATION_IGNORE_LIST.include? absence_duration
        return medical_certificate.data_de_emissao
      end

      absence_duration_format = MedicalCertificatesPresenter::ABSENCE_DURATION_FORMAT

      duration = absence_duration_format.match(absence_duration).named_captures

      return_date = medical_certificate.data_de_emissao
      return_date += duration['days'].to_i.days
      return_date += duration['hours'].to_i.hours
      return_date += duration['minutes'].to_i.minutes

      return_date.to_date
    end

    # Private: Extracts physician registry number
    #
    # Returns a String
    def format_physician_registry_number(registry_value)
      registry = PHYSICIAN_REGISTRY_FORMAT.match(registry_value).named_captures

      registry['number']
    end

    # Private: Extracts physician registry region state
    #
    # Returns a String
    def format_physician_registry_region(registry_value)
      registry = PHYSICIAN_REGISTRY_FORMAT.match(registry_value).named_captures

      registry['region']
    end

    # Private: Define if employee is appropriate or not
    # by checking CID value
    def format_examination_result(description)
      if description == REPORT_DEFAULTS[:appropriate_description]
        REPORT_DEFAULTS.dig(:aso_results, :appropriate)
      else
        REPORT_DEFAULTS.dig(:aso_results, :inapt)
      end
    end
  end
end
