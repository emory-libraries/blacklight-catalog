# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Flipflop Dashboard', type: :feature do
  context 'when a user is logged in' do
    before do
      sign_in(user)
    end

    context 'and is an admin' do
      let(:user) { User.create(uid: 'test', role: :admin) }

      it 'loads flipflop dashboard' do
        visit '/features'
        expect(status_code).to eq(200)
        expect(page).to have_content('Blacklight Catalog Features')
      end
    end

    context 'and is a guest' do
      let(:user) { User.create(uid: 'test', role: :guest) }

      it 'does not load the flipflop dashboard' do
        visit '/features'
        expect(status_code).to eq(403)
        expect(page.body).to eq('')
      end
    end
  end

  context 'when no user is logged in' do
    it 'does not load the flipflop dashboard' do
      visit '/features'
      expect(status_code).to eq(403)
      expect(page.body).to eq('')
    end
  end
end
