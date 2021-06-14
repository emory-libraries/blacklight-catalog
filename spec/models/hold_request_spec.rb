# frozen_string_literal: true
require 'rails_helper'
WebMock.allow_net_connect!
RSpec.describe HoldRequest do
  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_USER_KEY']
    ENV['ALMA_API_URL'] = 'http://www.example.com'
    ENV['ALMA_USER_KEY'] = "fakeuserkey456"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_USER_KEY'] = orig_key
  end

  let(:user) { User.create(uid: "janeq") }

  it "sets the body with the params" do
    sr = stub_request(:post, "http://www.example.com/almaws/v1/users//requests?allow_same_request=false&apikey=fakeuserkey456&mms_id=&user_id_type=all_unique")
         .with(
        body: {
          "request_type": "HOLD",
          "pickup_location_type": "LIBRARY",
          "pickup_location_library": "pull",
          "pickup_location_institution": "01GALI_EMORY",
          "comment": "I love cheese",
          "last_interest_date": "2021-06-10"
        }
      )
    k = described_class.new(pickup_library: "pull", comment: "I love cheese", not_needed_after: "2021-06-10")
    k.hold_request_response
    expect(sr).to have_been_made.once
  end

  it "only calls restclient once in hold_request_response" do
    sr = stub_request(:post, "http://www.example.com/almaws/v1/users//requests?allow_same_request=false&apikey=fakeuserkey456&mms_id=&user_id_type=all_unique")
    k = described_class.new
    k.hold_request_response
    k.hold_request_response
    expect(sr).to have_been_made.once
  end

  it "has a holding id available" do
    hr = described_class.new(holding_id: "456")
    expect(hr.holding_id).to eq "456"
  end

  it "can persist a holding request to Alma" do
    hr = described_class.new(mms_id: "9936550118202486", user: user)
    hr.save
    expect(hr.id).to eq "36181952270002486"
  end

  it "can find an existing holding request in Alma" do
    hr = described_class.find(id: "36181952270002486", user: user)
    expect(hr.mms_id).to eq "9936550118202486"
  end

  it "build the correct for a title request" do
    hr = described_class.new(mms_id: "9936550118202486", holding_id: "22332597410002486", user: user)
    expected_url = "http://www.example.com/almaws/v1/users/janeq/requests?user_id_type=all_unique&mms_id=9936550118202486&allow_same_request=false&apikey=fakeuserkey456"
    expect(hr.title_request_url).to eq expected_url
  end

  it "gives a list of allowed libraries for pickup for an Oxford user with an Oxford book" do
    stub_request(:get, "http://www.example.com/almaws/v1/users/janeq?user_id_type=all_unique&view=full&expand=none&apikey=fakeuserkey456")
      .to_return(status: 200, body: File.read(fixture_path + '/alma_users/full_user_record_oxford.xml'), headers: {})
    hr = described_class.new(mms_id: "9936550118202486", holding_id: "22332597410002486", user: user, holding_library: { label: "Oxford College Library", value: "OXFD" })
    expect(user.oxford_user?).to eq true
    expect(hr.pickup_library_options).to eq([{ label: "Oxford College Library", value: "OXFD" }])
    expect(hr.holding_library).to eq({ label: "Oxford College Library", value: "OXFD" })
  end
  it "gives a list of allowed libraries for pickup for a non-Oxford user for an Oxford book" do
    stub_request(:get, "http://www.example.com/almaws/v1/users/janeq?user_id_type=all_unique&view=full&expand=none&apikey=fakeuserkey456")
      .to_return(status: 200, body: File.read(fixture_path + '/alma_users/full_user_record.xml'), headers: {})
    hr = described_class.new(mms_id: "9936550118202486", holding_id: "22332597410002486", user: user, holding_library: { label: "Oxford College Library", value: "OXFD" })
    expect(user.oxford_user?).to eq false
    expect(hr.pickup_library_options).to eq(described_class.pickup_libraries)
    expect(hr.holding_library).to eq({ label: "Oxford College Library", value: "OXFD" })
  end

  it "gives a list of allowed libraries for pickup for a non-Oxford user for Media from the Music library" do
    stub_request(:get, "http://www.example.com/almaws/v1/users/janeq?user_id_type=all_unique&view=full&expand=none&apikey=fakeuserkey456")
      .to_return(status: 200, body: File.read(fixture_path + '/alma_users/full_user_record.xml'), headers: {})
    hr = described_class.new(mms_id: "9936984306602486", holding_id: "22391093010002486", user: user, holding_library: { label: "Marian K. Heilbrun Music Media", value: "MUSME" },
                             holding_location: { label: "Media Collection", value: "MEDIA" })
    expect(user.oxford_user?).to eq false
    expect(hr.pickup_library_options).to eq([{ label: "Marian K. Heilbrun Music Media", value: "MUSME" }])
    expect(hr.holding_library).to eq({ label: "Marian K. Heilbrun Music Media", value: "MUSME" })
  end
end
