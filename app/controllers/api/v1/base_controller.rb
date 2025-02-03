class Api::V1::BaseController < ActionController::API
  acts_as_token_authentication_handler_for Empresa

  respond_to :json
end
