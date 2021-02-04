# frozen_string_literal: true
class SessionsController < Devise::SessionsController
  include BlacklightAlma::Sso
end
