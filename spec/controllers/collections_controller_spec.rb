# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CollectionsController, type: :controller do
  before do
    col = Qa::LocalAuthority.find_or_create_by(name: 'collections')
    Qa::LocalAuthorityEntry.create(local_authority: col, uri: 'Example1')
    Qa::LocalAuthorityEntry.create(local_authority: col, uri: 'Blacklight1')
  end

  context '#search' do
    it 'will return correct result' do
      get :search, params: { uri: 'ex' }
      expect(JSON.parse(response.body)["collection_result"]).to eq(['Example1'])
    end
  end
end
