module AuthenticateWithOtpTwoFactor
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_with_two_factor, if: :two_factor_enabled?
  end

  private

  def two_factor_enabled?
    current_user.otp_required_for_login?
  end

  def authenticate_with_two_factor
    "ok"
  end
end