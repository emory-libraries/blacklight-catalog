# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Features Page', type: :system, js: false do
  context 'when user is ltds admin' do
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: 'shibboleth',
        uid: "ltds_admin",
        info: {
          display_name: "LTDS Admin",
          uid: 'ltds_admin',
          mail: 'ltds_admin@emory.edu'
        }
      )
    end
    let(:user) { User.from_omniauth(auth_hash) }

    it 'loads successfully' do
      allow(user).to receive(:ltds_admin_user?).and_return(true)
      sign_in(user)
      visit '/features'
      expect(page.status_code).to eq(200)
    end
  end

  context 'when user is not ltds admin' do
    let(:user) { User.create(uid: "test") }

    it 'does not load due to forbidden access' do
      allow(user).to receive(:ltds_admin_user?).and_return(false)
      sign_in(user)
      visit '/features'
      expect(page.status_code).to eq(403)
    end
  end
end
