# frozen_string_literal: true
require 'rails_helper'
require 'rest-client'
include Warden::Test::Helpers

RSpec.describe 'get it and view it tabs', type: :system, js: true do
  let(:user) { User.create(uid: 123, provider: 'shibboleth') }
  before do
    delete_all_documents_from_solr
    solr = Blacklight.default_index.connection
    solr.add(TEST_ITEM)
    solr.commit
  end

  around do |example|
    ENV["ALMA"] = "smackety"
    ENV["INSTITUTION"] = "blah"
    example.run
    ENV["ALMA"] = ""
    ENV["INSTITUTION"] = ""
  end

  context "getit tab" do
    context 'not logged in' do
      it 'does not show get it options' do
        visit "/catalog/123"
        click_on 'Physical copy'
        expect(find("#request-options")["src"]).to eq(find("#physical-123")["data-url"])
        expect(find("#request-options")["src"]).not_to include("sso=true") # when not logged in
        expect(find("#request-options")["src"]).to include("getit")
      end
    end

    context 'logged in' do
      it 'shows request options' do
        login_as user
        visit "/catalog/123"
        click_on 'Physical copy'
        expect(find("#request-options")["src"]).to include("sso=true")
        expect(find("#request-options")["src"]).to include("getit")
      end
    end
  end

  context "viewit tab" do
    it 'shows viewit options' do
      visit "/catalog/123"
      click_on 'On-line version'
      expect(find("#request-options")["src"]).to eq(find("#online-123")["data-url"])
      expect(find("#request-options")["src"]).to include("viewit")
    end
  end
end
