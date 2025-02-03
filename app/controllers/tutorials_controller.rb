class TutorialsController < ApplicationController
  include AccountScope

  require_authentication!

  layout 'redesign'

  def index
    @videos = [
      { url: 'https://1drv.ms/v/s!Av63sXCKdnexyQKJtJRUpK4ricFb?e=LfHaob/embed', title: 'Conheça a Siklee' },
      { url: 'https://1drv.ms/v/s!Av63sXCKdnexyQWWeMkfR8Ofmx-N?e=NtDvIx/embed', title: 'Objetivos e Informações Básicas' },
      { url: 'https://1drv.ms/v/s!Av63sXCKdnexyQOPymStHyqtMfaC?e=pS75O2/embed', title: 'Tipos de Atestado e como enviar' },
      { url: 'https://1drv.ms/v/s!Av63sXCKdnexyQ1UZxu9GStIb9dd?e=bajvsK/embed', title: 'Declaração de Comparecimento' },
      { url: 'https://1drv.ms/v/s!Av63sXCKdnexySVzJ8LlPoMaquAs?e=gjvY9H/embed', title: 'Atestado Médico' },
      { url: 'https://1drv.ms/v/s!Av63sXCKdnexySRZN1orh7h0TTB0?e=3hYo77/embed', title: 'Atestado de Acompanhante' },
      { url: 'https://1drv.ms/v/s!Av63sXCKdnexySbEGh6MCUXk9PWH?e=lE188f/embed', title: 'Atestado de Saúde Ocupacional (ASO)' },
      { url: 'https://1drv.ms/v/s!Av63sXCKdnexyScCiO2CHLgtAp-4?e=cDQMl2/embed', title: 'Fluxo de Aprovação' }
    ]
  end
end
