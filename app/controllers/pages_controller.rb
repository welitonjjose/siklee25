class PagesController < ApplicationController
  # layout 'redesign', only: :lgpd_text

  before_action :redirect_authenticated_to_dashboard, only: :home

  def home
  end

  def consultant
  end

  def contact
  end

  def lgpd_text
  end

  protected

  def redirect_authenticated_to_dashboard
    redirect_to dashboard_path if current_user
  end
end
