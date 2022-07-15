# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Admin::ContentBlocksController, type: :controller do
  describe '#index' do
    context 'when a user is logged in' do
      before do
        sign_in(user)
      end

      context 'and is an admin' do
        let(:user) { User.create(uid: 'test', role: :admin) }

        it 'loads content blocks dashboard' do
          get :index
          expect(response).to have_http_status(:success)
        end
      end

      context 'and is a guest' do
        let(:user) { User.create(uid: 'test', role: :guest) }

        it 'denies access to the content blocks dashboard' do
          expect { get :index }.to raise_error CanCan::AccessDenied
        end
      end
    end

    context 'when no user is logged in' do
      it 'denies access to the content blocks dashboard' do
        expect { get :index }.to raise_error CanCan::AccessDenied
      end
    end
  end

  describe '#show' do
    let!(:content_block) { FactoryBot.create(:content_block) }

    context 'when a user is logged in' do
      before do
        sign_in(user)
      end

      context 'and is an admin' do
        let(:user) { User.create(uid: 'test', role: :admin) }

        it 'loads the content block' do
          get :show, params: { id: content_block.id }
          expect(response).to have_http_status(:success)
        end
      end

      context 'and is a guest' do
        let(:user) { User.create(uid: 'test', role: :guest) }

        it 'denies access to the content block' do
          expect { get :show, params: { id: content_block.id } }.to raise_error CanCan::AccessDenied
        end
      end
    end

    context 'when no user is logged in' do
      it 'denies access to the content block' do
        expect { get :show, params: { id: content_block.id } }.to raise_error CanCan::AccessDenied
      end
    end
  end

  describe '#update' do
    let!(:content_block) { FactoryBot.create(:content_block) }

    context 'when a user is logged in' do
      before do
        sign_in(user)
      end

      context 'and is an admin' do
        let(:user) { User.create(uid: 'test', role: :admin) }

        it 'enables user to update the content block' do
          put :update, params: { "content_block" => { "value" => "new_value" }, "id" => content_block.id.to_s }
          expect(response).to have_http_status(:found)
          content_block.reload
          expect(content_block.value).to eq('new_value')
        end
      end

      context 'and is a guest' do
        let(:user) { User.create(uid: 'test', role: :guest) }

        it 'denies access to the content block' do
          expect { put :update, params: { "content_block" => { "value" => "hello_world" }, "id" => content_block.id.to_s } }.to raise_error CanCan::AccessDenied
        end
      end
    end

    context 'when no user is logged in' do
      it 'denies access to the content block' do
        expect { put :update, params: { "content_block" => { "value" => "hello_world" }, "id" => content_block.id.to_s } }.to raise_error CanCan::AccessDenied
      end
    end
  end

  describe '#destroy' do
    let!(:content_block) { FactoryBot.create(:content_block) }

    context 'when a user is logged in' do
      before do
        sign_in(user)
      end

      context 'and is an admin' do
        let(:user) { User.create(uid: 'test', role: :admin) }

        it 'is not permitted' do
          expect { delete :destroy, params: { id: content_block.id } }.to raise_error CanCan::AccessDenied
        end
      end

      context 'and is a guest' do
        let(:user) { User.create(uid: 'test', role: :guest) }

        it 'is not permitted' do
          expect { delete :destroy, params: { id: content_block.id } }.to raise_error CanCan::AccessDenied
        end
      end
    end

    context 'when no user is logged in' do
      it 'is not permitted' do
        expect { delete :destroy, params: { id: content_block.id } }.to raise_error CanCan::AccessDenied
      end
    end
  end
end
