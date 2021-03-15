# frozen_string_literal: true
class OmniauthController < Devise::SessionsController
  def new
    Rails.logger.debug "SessionsController#new: request.referer = #{request.referer}"
    if Rails.env.production?
      session[:requested_page] = request.referer if current_user.blank?
      redirect_to user_shibboleth_omniauth_authorize_path
    else
      super
    end
  end
end
