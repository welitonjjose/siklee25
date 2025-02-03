class EmployeeCreationService
  InvalidRole = Class.new(StandardError)

  attr_reader :resource, :bond,
    :company_id, :generated_password

  def initialize(params, author, role)
    @company_id = fetch_company_by(
      author: author,
      role: role
    )

    params[:vinculos_attributes][0][:empresa_id] = @company_id
    @resource = find_funcionario(cpf: params[:cpf]) || Funcionario.new
    @resource.assign_attributes(params)

    # @bond = Vinculo.new(params[:vinculos_attributes][0])


    @generated_password = Devise.friendly_token.first(8)
  end

  def call
    creation_result = false
    resource.password ||= generated_password
    resource.password_confirmation ||= generated_password

    creation_result = resource.save

    if creation_result
      send_welcome_email
    end

    creation_result
  end

  private

  def find_funcionario(cpf: )
    Funcionario.find_by(cpf: cpf)
  end

  def fetch_company_by(author:, role:)
    case role
    when :company
      author.id
    when :employee
      author.most_recent_bond.empresa_id
    else
      raise InvalidRole
    end
  end

  def send_welcome_email
    AccountMailer.welcome(
      resource,
      role: :employee,
      generated_password: generated_password
    ).deliver_now
  end
end
