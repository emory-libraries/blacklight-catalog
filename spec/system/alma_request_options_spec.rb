# frozen_string_literal: true
require 'rails_helper'
require 'rest-client'
include Warden::Test::Helpers

RSpec.describe 'get it and view it iframes', type: :system, js: true do
  let(:user) { User.create(uid: 123, provider: 'shibboleth') }
  before do
    delete_all_documents_from_solr
    build_solr_docs(TEST_ITEM)
  end

  around do |example|
    ENV["ALMA"] = "smackety"
    ENV["INSTITUTION"] = "blah"
    example.run
    ENV["ALMA"] = ""
    ENV["INSTITUTION"] = ""
  end

  context "getit iframe" do
    it 'shows the right iframe' do
      visit "/catalog/123"
      iframe = find("#request-options-physical")["src"]

      expect(iframe).to include("getit")
      ["sso=true", "viewit"].each { |s| expect(iframe).not_to include(s) }
    end
  end

  context "viewit iframe" do
    before do
      delete_all_documents_from_solr
      build_solr_docs(TEST_ITEM.dup.merge(id: '456'))
    end

    it 'shows the right iframe' do
      visit "/catalog/456"
      iframe = find("#request-options-online")["src"]

      expect(iframe).to include("viewit")
      ["sso=true", "getit"].each { |s| expect(iframe).not_to include(s) }
    end
  end
end
