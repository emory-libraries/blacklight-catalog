require 'rails_helper'
require 'alma_repo'
WebMock.allow_net_connect!
RSpec.describe AlmaRepo do
  let(:bad_api) { File.read "spec/fixtures/alma_bad_api_key.xml" }
  let(:good_holdings) { File.read("spec/fixtures/alma_holdings_doc.xml") }
  let(:good_req_options) { File.read("spec/fixtures/good_req_options.xml") }
  let(:no_req_options) { File.read("spec/fixtures/no_hold_options.xml") }
  let(:good_user_info) { File.read("spec/fixtures/good_user_info.xml") }
  let(:bad_api_ex){
    instance_double(RestClient::BadRequest, :response=>bad_api)
  }

  it "fails with bad api key a request" do
    stub_request(:get, AlmaRepo.request_options_url("mloone2", 9, "some_api_key")).to_raise(RestClient::BadRequest.new(bad_api, 400))
    expect(AlmaRepo.check_request("mloone2", "9", "some_api_key")).to eq([:error, "API-key not defined or not configured to allow this API."])
  end

  it "succeeds the happy path good params" do
    alma_user_key=ENV.fetch("ALMA_USER_KEY")
    bib= '9937224214202486'
    uid="mloone2"
    stub_request(:get, AlmaRepo.request_options_url(uid, bib, alma_user_key)).to_return(status: 200, body: good_req_options)
    stub_request(:get, AlmaRepo.retrieve_holdings_url(bib, alma_user_key)).to_return(status: 200, body: good_holdings)
    stub_request(:get, AlmaRepo.user_group_url(uid, alma_user_key)).to_return(status: 200, body: good_user_info)
    expect(AlmaRepo.check_request("mloone2", bib,alma_user_key)).to eq([:ok, true, ["HLTH", "LAW", "LSC", "MUSME", "OXFD", "THEO", "UNIV", "UNIVLOCK"], "22442434140002486", "MUSME"])
  end
end
