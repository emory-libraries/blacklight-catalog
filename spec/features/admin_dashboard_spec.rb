# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Dashboard', type: :feature do
  before do
    sign_in(user)
  end

  context 'when user is an admin' do
    let(:user) { User.create(uid: 'test', role: :admin) }

    it 'loads admin dashboard' do
      visit admin_path
      expect(status_code).to eq(200)
      expect(page).to have_content('Admin Dashboard')
    end
  end

  context 'when user is a guest' do
    let(:user) { User.create(uid: 'test', role: :guest) }

    it 'does not load the admin dashboard' do
      visit admin_path
      expect(status_code).to eq(500)
      expect(page).not_to have_content('Admin Dashboard')
    end
  end
end
