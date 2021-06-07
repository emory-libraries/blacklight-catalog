# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Create a request for a holding", type: :system, js: true, alma: true do
  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_BIB_KEY']
    ENV['ALMA_API_URL'] = 'www.example.com'
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_BIB_KEY'] = orig_key
  end

  let(:solr_doc) { described_class.find(MLA_HANDBOOK[:id]) }
  let(:user) { User.create(uid: "foo") }

  before do
    delete_all_documents_from_solr
    solr = Blacklight.default_index.connection
    solr.add(MLA_HANDBOOK)
    solr.commit
  end

  it "has a button to request holdings" do
    visit solr_document_path(MLA_HANDBOOK[:id])
    sign_in(User.new(uid: "foo"))
    within '#physical-holding-1' do
      expect(page).to have_button("Request")
      click_on("Request")
    end
    expect(page).to have_content('Pickup library')
  end

  it "has a dropdown list of possible pickup libraries" do
    sign_in(user)
    visit new_holding_requests_path(params: { holding_id: "789" })
    expect(page).to have_field('Holding', with: '789', readonly: true)
    page.select 'Law Library', from: 'Pickup library'
    click_on("Create Holding request")
    expect(page).to have_content("Pickup library")
  end
end
