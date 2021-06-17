# frozen_string_literal: true
require 'rails_helper'

RSpec.describe HoldRequest do
  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_user_key = ENV['ALMA_USER_KEY']
    orig_bib_key = ENV['ALMA_BIB_KEY']
    ENV['ALMA_API_URL'] = 'http://www.example.com'
    ENV['ALMA_USER_KEY'] = "fakeuserkey456"
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_USER_KEY'] = orig_user_key
    ENV['ALMA_BIB_KEY'] = orig_bib_key
  end

  before do
    stub_request(:post, "http://www.example.com/almaws/v1/users/janeq/requests?user_id_type=all_unique&mms_id=9936550118202486&allow_same_request=false&apikey=fakeuserkey456")
      .to_return(status: 200, body: File.read(fixture_path + '/alma_request_test_file.json'))
  end

  let(:user) { User.create(uid: "janeq") }

  context "validates attributes" do
    it "validates the presence of the pickup location library" do
      hr = described_class.new(mms_id: "9936550118202486")
      expect(hr.valid?).to be false
    end

    it "validates the presence of an mms_id" do
      hr = described_class.new(pickup_library: "pull")
      expect(hr.valid?).to be false
    end

    it "validates the presence of physical holdings" do
      hr = described_class.new(mms_id: "9937275387802486", pickup_library: "pull")
      expect(hr.valid?).to be false
    end

    it "validates as true if physical holdings, pickup library, and mms_id are all present" do
      hr = described_class.new(mms_id: "9936550118202486", pickup_library: "pull")
      expect(hr.valid?).to be true
    end
  end

  context "formatting dates" do
    let(:valid_attributes) do
      {
        "user": user,
        "mms_id": "9936550118202486",
        "pickup_library": "MUSME",
        "comment": "IGNORE - TESTING",
        "not_needed_after(1i)": "2021",
        "not_needed_after(2i)": "6",
        "not_needed_after(3i)": "10"
      }
    end
    it "formats the last_interest_date field for Alma" do
      k = described_class.new(valid_attributes)
      expect(k.valid?).to be true
      expect(k.last_interest_date).to eq "2021-06-10Z"
    end
  end

  it "sets the body with the params" do
    sr_bib = stub_request(:get, "http://www.example.com/almaws/v1/bibs/9936550118202486?apikey=fakebibkey123&expand=p_avail,e_avail,d_avail,requests&view=full")
             .to_return(status: 200, body: File.read(fixture_path + '/alma_availability_test_file_6.xml'), headers: {})
    sr_post = stub_request(:post, "http://www.example.com/almaws/v1/users//requests?allow_same_request=false&apikey=fakeuserkey456&mms_id=9936550118202486&user_id_type=all_unique")
              .with(
        body: {
          "request_type": "HOLD",
          "pickup_location_type": "LIBRARY",
          "pickup_location_library": "pull",
          "pickup_location_institution": "01GALI_EMORY",
          "comment": "I love cheese",
          "holding_id": "22360885950002486",
          "last_interest_date": "2021-06-10Z"
        }
      )
    k = described_class.new(mms_id: "9936550118202486", pickup_library: "pull", comment: "I love cheese", "not_needed_after(1i)": "2021", "not_needed_after(2i)": "6", "not_needed_after(3i)": "10")
    expect(k.valid?).to eq true
    k.hold_request_response
    expect(sr_post).to have_been_made.once
    expect(sr_bib).to have_been_made.once
  end

  it "only calls restclient once in hold_request_response" do
    sr_post = stub_request(:post, "http://www.example.com/almaws/v1/users//requests?allow_same_request=false&apikey=fakeuserkey456&mms_id=9936550118202486&user_id_type=all_unique")
    k = described_class.new(mms_id: "9936550118202486", pickup_library: "pull")
    k.hold_request_response
    k.hold_request_response
    expect(sr_post).to have_been_made.once
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
    hr = described_class.new(mms_id: "9936550118202486", user: user)
    expect(hr.physical_holdings).to be
    expect(hr.holding_libraries).to be_an_instance_of Array
    expect(user.oxford_user?).to eq true
    expect(hr.pickup_library_options).to eq([{ label: "Oxford College Library", value: "OXFD" }])
  end
  it "gives a list of allowed libraries for pickup for a non-Oxford user" do
    stub_request(:get, "http://www.example.com/almaws/v1/users/janeq?user_id_type=all_unique&view=full&expand=none&apikey=fakeuserkey456")
      .to_return(status: 200, body: File.read(fixture_path + '/alma_users/full_user_record.xml'), headers: {})
    hr = described_class.new(mms_id: "9936550118202486", user: user)
    expect(user.oxford_user?).to eq false
    expect(hr.pickup_library_options).to eq(described_class.pickup_libraries)
    expect(hr.holding_library).to eq({ label: "Robert W. Woodruff Library", value: "UNIV" })
  end

  it "gives a list of allowed libraries for pickup for a non-Oxford user for Media from the Music library" do
    # WebMock.allow_net_connect!
    stub_request(:get, "http://www.example.com/almaws/v1/users/janeq?user_id_type=all_unique&view=full&expand=none&apikey=fakeuserkey456")
      .to_return(status: 200, body: File.read(fixture_path + '/alma_users/full_user_record.xml'), headers: {})
    stub_request(:get, "http://www.example.com/almaws/v1/bibs/9936984306602486?apikey=fakebibkey123&expand=p_avail,e_avail,d_avail,requests&view=full")
      .to_return(status: 200, body: File.read(fixture_path + '/alma_bib_records/sound_recording.xml'), headers: {})
    stub_request(:get, "http://www.example.com/almaws/v1/bibs/9936984306602486/holdings/22391093010002486/items?apikey=fakebibkey123")
      .to_return(status: 200, body: File.read(fixture_path + '/alma_item_records/sound_recording_item_record.xml'), headers: {})
    # user = User.create(uid: "mkadel")
    hr = described_class.new(mms_id: "9936984306602486", user: user)
    expect(user.oxford_user?).to eq false
    expect(hr.holding_to_request).to eq(hr.physical_holdings.first)
    expect(hr.pickup_library_options).to eq([{ label: "Marian K. Heilbrun Music Media", value: "MUSME" }])
    expect(hr.holding_library).to eq({ label: "Marian K. Heilbrun Music Media", value: "MUSME" })
  end
end
