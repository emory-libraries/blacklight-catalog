# frozen_string_literal: true
class OmniauthController < Devise::SessionsController
  def new
    Rails.logger.debug "SessionsController#new: request.referer = #{request.referer}"
    Rails.logger.debug "SessionsController#new: request.url = #{request.url}"
    if Rails.env.production?
      session[:requested_page] = request.url
      redirect_to user_shibboleth_omniauth_authorize_path
    else
      super
    end
  end
end
