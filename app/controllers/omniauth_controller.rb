# frozen_string_literal: true
class OmniauthController < Devise::SessionsController
  def new
    Rails.logger.debug "SessionsController#new: request.referer = #{request.referer}"
    Rails.logger.debug "current_user here? #{current_user.present?}"
    if Rails.env.production?
      session[:requested_page] = request.referer if current_user.blank?
      if current_user.present?
        redirect_to session[:requested_page] || root_path
      else
        redirect_to user_shibboleth_omniauth_authorize_path
      end
    else
      super
    end
  end
end
