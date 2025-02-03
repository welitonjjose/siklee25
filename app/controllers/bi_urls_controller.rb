class BiUrlsController < ApplicationController
  include AccountScope

  require_admin!

  layout 'redesign'

  def new
    @bi_url = BiUrl.new
  end

  def create
    @bi_url = BiUrl.new
    @bi_url.admin = current_admin
    @bi_url.bi_url = bi_url_params[:bi_url]

    if @bi_url.save
      redirect_to root_path
    else
      render :new
    end
  end

  private

  def bi_url_params
    params.require(:bi_url)
  end
end
