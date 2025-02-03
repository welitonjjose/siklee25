module ApplicationHelper
  def atestado_url(photo, options = {}, &block)
    return link_to('#', &block) if photo.nil? || photo.content_type == 'application/pdf'

    return link_to(photo.service_url, options, &block)
  end

  def logo(classes:)
    link_to '/', class: classes[:link] do
      if current_empresa&.logo.presence
        image_tag current_empresa.logo, class: classes[:image]
      elsif current_funcionario&.vinculos&.joins(:empresa)&.first&.empresa&.logo.presence
        image_tag current_funcionario.vinculos.first.empresa.logo, class: 'nav-logo'
      elsif current_app&.logo
        image_tag current_app.logo, class: classes[:image]
      else
        image_tag 'logos/siklee_medium.png', class: classes[:image]
      end
    end
  end

  def funcionarios_by_gestor
    current_vinculo = current_funcionario.vinculos.last
    empresa = current_vinculo.empresa
    Funcionario.select('funcionarios.id, funcionarios.nome')
               .joins(:vinculos)
               .where('vinculos.empresa_id': empresa.id)
               .where('vinculos.squad_id': current_vinculo.squad_id)
               .where('vinculos.ativo': true)
               .order('nome')
  end

  def squads_by_empresa
    empresa_id = if current_empresa
                   current_empresa.id
                 elsif current_funcionario
                   current_funcionario.vinculos.last.empresa_id
                 elsif current_consultant
                   current_consultant.authorized_company_ids
                 elsif current_consultant_team
                   current_consultant_team.authorized_company_ids
                 else
                   0
                 end
    Squad.select('id, name').where(empresa_id: empresa_id)
  end

  def squads_by_empresa_form id
    Squad.select('id, name').where(empresa_id: id)
  end

  def squads_by_user(company_id = nil)
    squads = Squad.select('id, name')
    squads = squads.where(empresa_id: company_id) if company_id

    return squads.all if current_admin

    return squads.where(empresa_id: current_empresa.id) if current_empresa

    return squads.where(empresa_id: current_consultant.authorized_company_ids) if current_consultant

    return squads.where(empresa_id: current_consultant_team.authorized_company_ids) if current_consultant_team

    return squads.where(empresa_id: current_funcionario.most_recent_bond.empresa_id) if current_funcionario.employer?

    squads.where(id: current_funcionario.most_recent_bond.squad_id)
  end

  def lideres_by_empresa(funcionario_id=nil)
    empresa_ids = if current_empresa
                   [current_empresa.id]
                 elsif current_funcionario
                   [current_funcionario.vinculos.last.empresa_id]
                 elsif current_consultant
                  current_consultant.authorized_company_ids
                 elsif current_consultant_team
                  current_consultant_team.authorized_company_ids
                 elsif current_admin
                  Empresa.all.pluck(:id)
                 else
                   0
                 end

    lideres = Vinculo.select('funcionarios.id as id, funcionarios.nome as name')
                     .joins(:funcionario)
                     .where('empresa_id in (?) and (vinculos.gestor = true or vinculos.empregador = true)', empresa_ids)

    if funcionario_id
      lideres = lideres.where.not(funcionario_id: funcionario_id)
    end

    lideres
  end

  def consultant_empresas
    current_user.empresas.select('empresas.id, empresas.razao_social as name')
  end

  def can_do?
    [:consultant, :collaborator].include?(current_role)
  end

  def can_do_employer?
    [:company].include?(current_role)
  end

  def has_role_permission?
    if current_user.class.to_s == "Funcionario"
      return true if !current_user.nil? && current_user.employer?
    end

    return true if company?
    return true if can_do?

    false
  end

  def has_role_permission_consultant?
    return false if current_user.class.to_s == "Consultant" || current_user.class.to_s == "ConsultantTeam"

    has_role_permission?
  end

  def qr_code_as_svg(uri)
    RQRCode::QRCode.new(uri).as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 4,
      standalone: true,
    ).html_safe
  end

  def set_registration_path
    classe = current_user.class.to_s.downcase
    if classe == "admin"
      st = "rails_admin_path"
    elsif classe == "consultantteam"
      st = "edit_consultant_team_registration_path"
    else
      st = "edit_#{current_user.class.to_s.downcase}_registration_path"
    end

    send(st)
  end
end
