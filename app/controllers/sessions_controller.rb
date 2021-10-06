# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  include Sessions::SocialLogin

  layout proc { false if request.xhr? }

  def new
    session[:requested_page] = request.referer || root_path
    super
  end
end
