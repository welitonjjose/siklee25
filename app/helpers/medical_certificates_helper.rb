module MedicalCertificatesHelper
  PDF_CONTENT_TYPE = 'application/pdf'

  EXAMINING_PHYSICIAN_INFO_ATTRS = %i[medico_examinador examinador_registro examinador_numero_registro
                                      uf_examinador examining_physician_status_on_cfm]

  PHYSICIAN_INFO_ATTRS = %i[nome_do_medico tipo_de_registro numero_de_registro
                            uf_medico especialidade_medica physician_status_on_cfm]

  FILTER_PARAMETERS = %i[
    company_id medical_certificate_type employee_id
    physican_name medical_specialty icd
    medical_institution origin employee_status
    department job_function
  ]

  AVATAR_OPTIONS = {
    default: {
      class: 'profile-pic'
    },
    uploaded: {
      class: 'profile-pic',
      crop: :fill,
      format: :jpg,
      cloud_name: :cloudinary
    }
  }

  def filtering_by_date?(date)
    return false unless date

    begin
      Date.parse(date)
    rescue ArgumentError
      return false
    end

    true
  end

  def include_examining_physician_info?(medical_certificate)
    EXAMINING_PHYSICIAN_INFO_ATTRS.find do |attr|
      return true if medical_certificate.send(attr)
    end

    false
  end

  def include_physician_info?(medical_certificate)
    PHYSICIAN_INFO_ATTRS.find do |attr|
      return true if medical_certificate.send(attr)
    end

    false
  end

  def preview_for(attachment:)
    url = fetch_url_for(attachment)

    if pdf?(attachment)
      pdf_preview_tag(url: url)
    else
      link_to url, target: "_blank" do
        image_preview_tag(url: url)
      end
    end
  end

  def profile_photo_for(resource, **options)
    if resource.is_a? Admin
      default_profile_photo(options)
    elsif resource&.photo&.attached?
      avatar_url = fetch_url_for(resource.photo)

      cl_image_tag avatar_url, AVATAR_OPTIONS[:uploaded].merge(options)
    else
      default_profile_photo(options)
    end
  end

  def default_profile_photo(options)
    image_tag 'default_avatar.jpg', AVATAR_OPTIONS[:default].merge(options)
  end

  def image_preview_tag(url:)
    cl_image_tag(url, crop: :fill, class: 'w-100 atestado-img', format: :jpg, cloud_name: :cloudinary)
  end

  def pdf?(attachment)
    attachment.blob.content_type == PDF_CONTENT_TYPE
  end

  def fetch_url_for(attachment)
    if Rails.env.production?
      url = attachment.service_url

      url.gsub!(/\.pdf$/, '.png') if pdf?(attachment)

      url
    else
      url_for(attachment)
    end
  end

  def pdf_preview_tag(url:)
    if Rails.env.production?
      cl_image_tag(url, format: :png, crop: :fill, class: 'w-96 atestado-img', cloud_name: :cloudinary)
    else
      content_tag(:iframe, '', src: url, class: 'preview-iframe', width: 565, height: 780, style: 'border: none;')
    end
  end

  def medical_certificate_types_values
    %i[presence default accompany aso].map do |type|
      Atestado::MEDICAL_CERTIFICATE_TYPES[type]
    end
  end

  def filtering_medical_certificate?
    FILTER_PARAMETERS.any? { |key| params[key].present? }
  end
end
