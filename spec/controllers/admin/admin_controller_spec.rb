# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Admin::AdminController, type: :controller do
  describe '#index' do
    context 'when a user is logged in' do
      before do
        sign_in(user)
      end

      context 'and is an admin' do
        let(:user) { User.create(uid: 'test', role: :admin) }

        it 'loads admin dashboard' do
          get :index
          expect(response).to have_http_status(:success)
        end
      end

      context 'and is a guest' do
        let(:user) { User.create(uid: 'test', role: :guest) }

        it 'denies access to the admin dashboard' do
          expect { get :index }.to raise_error CanCan::AccessDenied
        end
      end
    end

    context 'when no user is logged in' do
      it 'denies access to the admin dashboard' do
        expect { get :index }.to raise_error CanCan::AccessDenied
      end
    end
  end
end
