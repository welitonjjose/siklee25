class MedicalCertificatesReport
  DEFAULT_ENCODING = 'ISO-8859-1'

  I18N_TITLES_SCOPE = 'reports.csv.titles'

  ENUM_PREFIX = 'for_enum_'

  SUPPORTED_ENUM_CLASSES = {
    medical_certificate: {
      physician_status_on_cfm: CfmPhysicianStatuses,
      examining_physician_status_on_cfm: CfmPhysicianStatuses
    }
  }

  COLUMNS = {
    medical_certificate: %i[
      id nome_do_medico tipo_de_registro numero_de_registro especialidade_medica
      instituicao_de_saude cnpj endereco cidade estado cep telefone nome_funcionario
      cpf_funcionario rg_funcionario acesso_funcionario tipo_de_atestado data_de_emissao
      data_de_apresentacao descricao_do_afastamento tempo_de_dispensa cid
      funcionario_id created_at updated_at cfm empresa_id medico_examinador
      examinador_registro examinador_numero_registro uf_medico uf_examinador
      exames exames_complementares origem funcionario_corrigir
    ],
    employee: %i[data_nascimento sexo registro_empresa pis risco_ocupacional],
    bond: %i[squad cargo],
    company: %i[razao_social]
  }

  CSV_ADDITIONAL_COLUMNS = {
    medical_certificate: %i[
      funcionario_okay empresa_okay empresa_subscrever empresa_reverter
      for_enum_physician_status_on_cfm for_enum_examining_physician_status_on_cfm
    ]
  }

  XML_BUILDER = Nokogiri::XML::Builder

  class << self
    def csv(medical_certificates, date = nil)
      medical_certificates = apply_date_filter!(medical_certificates, date)

      CSV.generate(headers: true, encoding: DEFAULT_ENCODING) do |csv|
        title_row = build_title_row
        csv << title_row

        medical_certificates.each do |medical_certificate|
          employee = medical_certificate.funcionario
          bond = employee.vinculos.last
          company = bond.empresa

          row = []
          row.concat(columns_for(kind: :medical_certificate, resource: medical_certificate))

          row.concat(columns_for(source: CSV_ADDITIONAL_COLUMNS,
                                 kind: :medical_certificate,
                                 resource: medical_certificate))

          row.concat(columns_for(kind: :employee,resource: employee))
          row.concat(columns_for(kind: :bond,resource: bond))
          row.concat(columns_for(kind: :company,resource: company))

          csv << row
        end

        csv << build_total_row(title_row: title_row, resources: medical_certificates)
      end
    end

    def xml(medical_certificates)
      builder = XML_BUILDER.new(encoding: DEFAULT_ENCODING) do |xml|
        xml.atestados {
          medical_certificates.each do |medical_certificate|
            employee = medical_certificate.funcionario
            bond = employee.vinculos.last
            company = bond.empresa

            xml.atestado {
              COLUMNS[:medical_certificate].each do |column|
                translated_column = I18n.t(column, scope: I18N_TITLES_SCOPE)

                xml.send(translated_column, medical_certificate.send(column))
              end

              COLUMNS[:employee].each do |column|
                xml.send(column, employee.send(column))
              end

              COLUMNS[:bond].each do |column|
                xml.send(column, bond.send(column))
              end

              COLUMNS[:company].each do |column|
                xml.send(column, company.send(column))
              end
            }
          end
        }
      end

      builder.to_xml
    end

    # private

    def apply_date_filter!(medical_certificates, date)
      return medical_certificates unless date

      begin
        date = Date.parse(date)

        return medical_certificates.where(data_de_emissao: date)
      rescue ArgumentError
        return medical_certificates
      end
    end

    def columns_for(source: COLUMNS, kind:, resource:)
      source[kind].map do |column|
        if column.to_s.include? ENUM_PREFIX
          column = column.to_s.gsub(ENUM_PREFIX, '').to_sym

          value = resource.send(column)

          translate_for_enum(kind: kind, attr: column, value: value)
        else
          resource.send(column)
        end
      end
    end

    def build_title_row
      title_row = []

      COLUMNS.keys.each do |key|
        COLUMNS[key].each do |column|
          title_row << I18n.t(column, scope: I18N_TITLES_SCOPE)
        end

        next unless CSV_ADDITIONAL_COLUMNS[key]

        CSV_ADDITIONAL_COLUMNS[key].each do |column|
          title_row << I18n.t(column, scope: I18N_TITLES_SCOPE)
        end
      end

      title_row
    end

    def build_total_row(title_row:, resources:)
      presenter = MedicalCertificatesPresenter.new(resources)

      total_row = Array.new(title_row.count, '')
      total_row[0] = I18n.t(:total, scope: I18N_TITLES_SCOPE)

      absence_duration_index = find_index_for_absence_duration(title_row)
      total_row[absence_duration_index] = presenter.total_absence_duration

      total_row
    end

    def find_index_for_absence_duration(title_row)
      translated_absence_duration = I18n.t(:tempo_de_dispensa, scope: I18N_TITLES_SCOPE)
      title_row.find_index(translated_absence_duration)
    end

    def translate_for_enum(kind:, attr:, value:)
      SUPPORTED_ENUM_CLASSES[kind][attr].t(value)
    end
  end
end
