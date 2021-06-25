# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Create a request for a holding", type: :system, js: true, alma: true do
  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_BIB_KEY']
    orig_user_key = ENV['ALMA_USER_KEY']
    ENV['ALMA_API_URL'] = 'http://www.example.com'
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    ENV['ALMA_USER_KEY'] = "fakeuserkey456"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_BIB_KEY'] = orig_key
    ENV['ALMA_USER_KEY'] = orig_user_key
  end

  let(:solr_doc) { described_class.find(MLA_HANDBOOK[:id]) }
  let(:user) { User.create(uid: "janeq") }

  before do
    delete_all_documents_from_solr
    solr = Blacklight.default_index.connection
    solr.add(MLA_HANDBOOK)
    solr.commit
    stub_request(:get, "http://www.example.com/almaws/v1/users/janeq?user_id_type=all_unique&view=full&expand=none&apikey=fakeuserkey456")
      .to_return(status: 200, body: File.read(fixture_path + '/alma_users/full_user_record.xml'), headers: {})
    stub_request(:post, "http://www.example.com/almaws/v1/users/janeq/requests?user_id_type=all_unique&mms_id=9936550118202486&allow_same_request=false&apikey=fakeuserkey456")
      .to_return(status: 200, body: File.read(fixture_path + '/alma_request_test_file.json'))
    stub_request(:get, "http://www.example.com/almaws/v1/bibs/990011434390302486/holdings/22187557270002486/items?apikey=fakebibkey123&expand=due_date_policy&user_id=janeq")
      .to_return(status: 200, body: File.read(fixture_path + '/alma_item_records/22187557270002486.xml'), headers: {})
  end

  it "has a button to request a hold" do
    visit solr_document_path(MLA_HANDBOOK[:id])
    sign_in(user)
    within '.where-to-find-table' do
      find('.dropdown-toggle').click
      click_on("Hold request")
    end
    expect(page).to have_content("MLA handbook")
    expect(page).to have_field('Pickup library')
    expect(find_field('Pickup library')[:required]).to eq "true"
    expect(page).to have_field('Mms', with: MLA_HANDBOOK[:id], readonly: true)
    click_on("Create Hold request")
  end

  it "has a dropdown list of possible pickup libraries" do
    sign_in(user)
    visit new_hold_request_path(hold_request: { mms_id: MLA_HANDBOOK[:id] })
    page.select 'Law Library', from: 'Pickup library'
    click_on("Create Hold request")
    expect(page).to have_content("Hold Request")
    expect(page).to have_content('Hold request was successfully created.')
  end

  it 'has a dropdown with item level call number and description for unique item level descriptions' do
    sign_in(user)
    visit new_hold_request_path(hold_request: { mms_id: "990011434390302486" })
    expect(page).to have_select("hold_request_holding_item_id", with_options: ["ML549 .E38 V.21-24 2003-2006"])
  end
end
