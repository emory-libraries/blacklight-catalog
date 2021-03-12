# frozen_string_literal: true
class OmniauthController < Devise::SessionsController
  def new
    if Rails.env.production?
      session[:requested_page] = request.url
      redirect_to user_shibboleth_omniauth_authorize_path
    else
      super
    end
  end
end
