# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Dashboard', type: :feature do
  context 'when a user is logged in' do
    before do
      sign_in(user)
    end

    context 'and is an admin' do
      let(:user) { User.create(uid: 'test', role: :admin) }

      it 'loads admin dashboard' do
        visit admin_root_path
        expect(status_code).to eq(200)
        expect(page).to have_content('Admin Dashboard')
      end
    end

    context 'and is a guest' do
      let(:user) { User.create(uid: 'test', role: :guest) }

      it 'does not load the admin dashboard' do
        visit admin_root_path
        expect(status_code).to eq(500)
        expect(page).not_to have_content('Admin Dashboard')
      end
    end
  end

  context 'when no user is logged in' do
    it 'does not load the admin dashboard' do
      visit admin_root_path
      expect(status_code).to eq(500)
      expect(page).not_to have_content('Admin Dashboard')
    end
  end
end
