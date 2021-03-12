# frozen_string_literal: true
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def shibboleth
    Rails.logger.debug "OmniauthCallbacksController#shibboleth: request.env['omniauth.auth']: #{request.env['omniauth.auth']}"
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      set_flash_message :notice, :success, kind: "Shibboleth"
      sign_in @user
      redirect_to request.env["omniauth.origin"] || root_path
    else
      redirect_to root_path
      set_flash_message(:notice, :failure, kind: "Shibboleth", reason: "you aren't authorized to use this application.")
    end
  end
end
