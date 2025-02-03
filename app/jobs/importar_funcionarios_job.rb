class ImportarFuncionariosJob < ApplicationJob
  queue_as :default

  def perform(tmp_file, empresa_id)
    xlsx = Roo::Spreadsheet.open(tmp_file)
    #xlsx = Roo::Spreadsheet.open('/home/hamilton/Downloads/funcionarios.xlsx')
    sheet = xlsx.sheet(0)

    max_rows = sheet.last_row
    current_row = 2

    until current_row > max_rows do
      begin
        funcionario = Funcionario.new({
          nome:             sheet.cell(current_row, 1),
          cpf:              sheet.cell(current_row, 2),
          rg:               sheet.cell(current_row, 3),
          data_nascimento:  sheet.cell(current_row, 4).strftime('%d/%m/%Y'),
          sexo:             sheet.cell(current_row, 5),
          celular:          sheet.cell(current_row, 6),
          email:            sheet.cell(current_row, 7),
          registro_empresa: sheet.cell(current_row, 9),
          pis:              sheet.cell(current_row, 10),
          password:         sheet.cell(current_row, 11),
        })

        funcionario.save(validate: false)

        vinculo = Vinculo.new({
          empresa_id:     empresa_id,
          funcionario_id: funcionario.id,
          empregador:     false,
          cargo:          sheet.cell(current_row, 8),
          aprovado:       false
        })

        vinculo.save(validate: false)
      rescue
      end

      current_row += 1
    end
  end
end
