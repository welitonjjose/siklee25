class MedicalCertificatesPresenter
  ABSENCE_DURATION_FORMAT = /^((?<days>\d+)\ dias?)?(, | e )?((?<hours>\d+) horas?)?(, | e )?((?<minutes>\d+) minutos?)?$/

  HOUR_IN_MINUTES = 60
  DAY_IN_HOURS = 24

  TIME_LIMITS = {
    minutes: 59,
    hours: 23
  }.freeze

  SUFFIXES = {
    day: 'dia',
    hour: 'hora',
    minute: 'minuto'
  }.freeze

  attr_reader :medical_certificates

  def initialize(medical_certificates)
    @medical_certificates = medical_certificates
  end

  def total_absence_duration
    total_duration = medical_certificates.inject(empty_duration) do |total_duration, medical_certificate|
      if medical_certificate.tempo_de_dispensa && ABSENCE_DURATION_FORMAT.match(medical_certificate.tempo_de_dispensa)
        append_absence_duration(total_duration, medical_certificate.tempo_de_dispensa)
      else
        total_duration
      end
    end

    format_duration(total_duration)
  end

  private

  def append_absence_duration(total_duration, absence_duration)
    duration = ABSENCE_DURATION_FORMAT.match(absence_duration).named_captures
    normalized_duration = normalize_duration(duration)

    accumulated_minutes = sum_minutes(total_duration[:minutes], normalized_duration[:minutes])

    total_duration[:hours] += accumulated_minutes[:additional_hours]
    total_duration[:minutes] = accumulated_minutes[:total_minutes]

    accumulated_hours = sum_hours(total_duration[:hours], normalized_duration[:hours])

    total_duration[:days] += accumulated_hours[:additional_days] + normalized_duration[:days]
    total_duration[:hours] = accumulated_hours[:total_hours]

    total_duration
  end

  def format_duration(duration)
    days_suffix = duration[:days] == 1 ? SUFFIXES[:day] : "#{SUFFIXES[:day]}s"
    hours_suffix = duration[:hours] == 1 ? SUFFIXES[:hour] : "#{SUFFIXES[:hour]}s"
    minutes_suffix = duration[:minutes] == 1 ? SUFFIXES[:minute] : "#{SUFFIXES[:minute]}s"

    "#{duration[:days]} #{days_suffix}, #{duration[:hours]} #{hours_suffix} e #{duration[:minutes]} #{minutes_suffix}"
  end

  def normalize_duration(duration)
    {
      days: duration['days'].to_i,
      hours: duration['hours'].to_i,
      minutes: duration['minutes'].to_i
    }
  end

  def sum_minutes(total_minutes, minutes_to_add)
    {
      additional_hours: ((total_minutes + minutes_to_add) / HOUR_IN_MINUTES).to_i,
      total_minutes: (total_minutes + minutes_to_add) % TIME_LIMITS[:minutes]
    }
  end

  def sum_hours(total_hours, hours_to_add)
    {
      additional_days: ((total_hours + hours_to_add) / DAY_IN_HOURS).to_i,
      total_hours: (total_hours + hours_to_add) % TIME_LIMITS[:hours]
    }
  end

  def empty_duration
    { days: 0, hours: 0, minutes: 0 }
  end
end
