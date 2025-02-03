module MailersHelper
  ADDRESS_FIELDS = %i[endereco cidade estado cep]

  def absolute_public_image_url(image_path)
    host = Rails.application.config.action_mailer.asset_host

    "#{host}/#{image_path}"
  end

  def full_address_for(medical_certificate)
    full_address = ADDRESS_FIELDS.map do |field|
      medical_certificate.send(field)
    end.compact.reject(&:empty?)
  

    full_address.join(' - ')
  end

  def sign_in_url_for(recipient_role)
    case recipient_role
    when :employee
      new_funcionario_session_url
    when :company
      new_empresa_session_url
    else
      root_url
    end
  end

  private

  def image_extension(image_path)
    File.extname(image_path).delete_prefix('.')
  end
end
