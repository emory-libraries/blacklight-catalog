# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OmniauthController do
  describe '#new' do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      session[:requested_page] = '/requested_page'
    end

    context 'when the request referer is the sign in page' do
      it 'does not change the session requested page' do
        request.headers[:HTTP_REFERER] = '/sign_in'
        get :new
        expect(session[:requested_page]).to eq('/requested_page')
      end
    end

    context 'when the request referer is not the sign in page' do
      it 'sets the session requested page to the referer' do
        request.headers[:HTTP_REFERER] = '/example'
        get :new
        expect(session[:requested_page]).to eq('/example')
      end
    end
  end
end
