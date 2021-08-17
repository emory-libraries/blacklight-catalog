# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:token) do
    JWT.encode({ "iss" => "Alma", "aud" => "Primo", "exp" => (Time.current + 60).to_i,
                 "jti" => "A_fFAWACiQDF6vml7IzzMQ", "iat" => 1_623_698_969,
                 "nbf" => 1_623_698_849, "sub" => "patron", "id" => "bukowski1",
                 "name" => "BUKOWSKI, CHARLES", "email" => "example@example.com",
                 "provider" => "EMAIL" }, 'super_secret_key', 'HS256')
  end
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  around do |example|
    ENV['ALMA_AUTH_SECRET'] = 'super_secret_key'
    example.run
    ENV['ALMA_AUTH_SECRET'] = ''
  end

  context 'post call with bad params' do
    it 'redirects to root_path with error flash message' do
      post :social_login_callback, params: { jwt: 'foobar' }
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:error]).to be_present
    end
  end

  context 'post call with good params' do
    it 'redirects to root_path and signs user in' do
      post :social_login_callback, params: { jwt: token }
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to be(nil)
      expect(session[:alma_id]).to eq('bukowski1')
      expect(User.last.uid).to eq('bukowski1')
    end
  end
end
