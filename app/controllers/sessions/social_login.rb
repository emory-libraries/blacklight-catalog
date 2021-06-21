# frozen_string_literal: true

require 'jwt'

module Sessions::SocialLogin
  extend ActiveSupport::Concern

  # User gets redirected here after a successful login
  # via a social login provider.
  def social_login_callback
    begin
      decoded_jwt = JWT.decode(params[:jwt], ENV["ALMA_AUTH_SECRET"], true, algorithm: "HS256")
    rescue
      flash[:error] = "there was a problem with the returned JSON web token"
      redirect_to new_user_session_path and return
    end
    jwt = decoded_jwt[0]

    user = social_login_user_model.find_or_initialize_by(provider: jwt["provider"], uid: jwt["id"])
    user.assign_attributes(display_name: jwt["name"], email: jwt["email"])
    user.save!

    sign_in(:user, user)

    social_login_populate_session(jwt)

    redirect_to social_login_redirect
  end

  # populate the session
  def social_login_populate_session(jwt)
    session[:user_name] = jwt["name"]
    session[:alma_id] = jwt["id"]
    session[:alma_auth_type] = "social_login"
    session[:alma_social_login_provider] = jwt["provider"]
  end

  # @return [Class] class object to use for users
  def social_login_user_model
    User
  end

  # @return URL to redirect to after login
  def social_login_redirect
    request.referer || root_path
  end
end
