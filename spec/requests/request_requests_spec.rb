# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Requests', type: :request, alma: true do
  let(:user) do
    User.create(
      provider: 'shibboleth',
      uid: 'mkadel',
      display_name: 'Brian Wilson'
    )
  end

  before do
    login_as user
  end

  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_BIB_KEY']
    ENV['ALMA_API_URL'] = 'www.example.com'
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_BIB_KEY'] = orig_key
  end

  it "can get a json object with request information from alma" do
    get requests_path, params: { mms_id: "9937241630902486" }
    request_hash = JSON.parse(response.body)
    expect(request_hash["uid"]).to eq(user.uid)
    expect(request_hash["holding_id"]).to eq("22445410470002486") # Include holding ID for our test object
    expect(request_hash["holding_library"]).to eq("UNIV") # Include holding Library for our test object
  end
end
