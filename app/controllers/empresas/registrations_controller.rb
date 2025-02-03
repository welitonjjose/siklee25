# frozen_string_literal: true

class Empresas::RegistrationsController < Devise::RegistrationsController
  include AccountScope

  require_admin! only: %i[new create]

  layout 'redesign'
end
