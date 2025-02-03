# frozen_string_literal: true

class Funcionarios::PasswordExpiredController < Devise::PasswordExpiredController
  layout 'login'
end