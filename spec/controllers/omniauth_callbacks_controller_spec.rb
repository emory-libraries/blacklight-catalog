# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OmniauthCallbacksController do
  before do
    User.create(
      provider: 'shibboleth',
      uid: 'brianbboys1967',
      display_name: 'Brian Wilson'
    )
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:shib]
    post :shibboleth
  end

  OmniAuth.config.mock_auth[:shib] =
    OmniAuth::AuthHash.new(
      provider: 'shibboleth',
      uid: "P0000001",
      info: {
        display_name: "Brian Wilson",
        uid: 'brianbboys1967'
      }
    )

  context "when both origin and requested_page are present" do
    before do
      request.env["omniauth.origin"] = '/example'
      session[:requested_page] = '/example/1'
      post :shibboleth
    end

    it "redirects to origin" do
      expect(response.redirect_url).to eq 'http://test.host/example/1'
    end
  end

  context "when requested_page is missing" do
    before do
      request.env["omniauth.origin"] = '/example'
      post :shibboleth
    end

    it "redirects to origin" do
      expect(response.redirect_url).to include 'http://test.host/example'
    end
  end

  context "when both are missing" do
    it "redirects to home" do
      expect(response.redirect_url).to include 'http://test.host/'
    end
  end
end
