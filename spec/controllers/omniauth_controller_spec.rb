# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OmniauthController do
  describe '#new' do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context 'when the request referer is the sign in page' do
      it 'sets the session requested page to the root path' do
        request.headers[:HTTP_REFERER] = '/sign_in'
        get :new
        expect(session[:requested_page]).to eq(root_path)
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
