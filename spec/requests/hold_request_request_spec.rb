# frozen_string_literal: true
require "rails_helper"
RSpec.describe "hold request new", type: :request do
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
  context "as a logged in user" do
    let(:user) { User.create(uid: "janeq") }
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

    let(:invalid_attributes) do
      {
        "user": user.uid,
        "mms_id": "9936550118202486",
        "comment": "IGNORE - TESTING",
        "not_needed_after(1i)": "2021",
        "not_needed_after(2i)": "6",
        "not_needed_after(3i)": "10"
      }
    end

    before do
      sign_in(user)
      stub_request(:get, "http://www.example.com/almaws/v1/users/janeq?apikey=fakeuserkey456&expand=none&user_id_type=all_unique&view=full")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_users/full_user_record.xml'), headers: {})
    end
    it "renders the new template" do
      get new_hold_request_path, params: { hold_request: valid_attributes }
      expect(response).to render_template(:new)
      # expect(assigns(:hold_request).holding_id).to eq "4567"
      # expect(assigns(:hold_request).holding_library).to eq({ label: "Oxford College Library", value: "OXFD" })
      # expect(assigns(:hold_request).holding_location).to eq({ label: "Media Collection", value: "MEDIA" })
    end

    it "can create a holding request" do
      stub_request(:post, "http://www.example.com/almaws/v1/users/janeq/requests?user_id_type=all_unique&mms_id=9936550118202486&allow_same_request=false&apikey=fakeuserkey456")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_request_test_file.json'))
      post hold_requests_path, params: { hold_request: valid_attributes }
      expect(response).to redirect_to(hold_request_path("36181952270002486"))
      follow_redirect!
      expect(flash[:notice]).to eq('Hold request was successfully created.')
      expect(response).to render_template(:show)
      expect(response.body).to include('Hold request was successfully created.')
      expect(response.body).to include("36181952270002486")
      expect(response.body).to include("MUSME")
      expect(response.body).to include("IGNORE - TESTING")
    end

    it "renders a successful response" do
      get hold_request_path("36181952270002486")
      expect(response).to be_successful
      expect(response).to render_template(:show)
      expect(response.body).to include("36181952270002486")
      expect(response.body).to include("MUSME")
      expect(response.body).to include("IGNORE - TESTING")
    end

    it "validates the presence of a Pickup Library" do
      post hold_requests_path, params: { hold_request: invalid_attributes }
      expect(response).to redirect_to(new_hold_request_path(params: { hold_request: invalid_attributes }))
      # expect(response).to redirect_to(new_hold_request_path)
      follow_redirect!
      expect(flash[:errors]).to eq(["Pickup library can't be blank"])
      expect(response.body).to include("Pickup library can&#39;t be blank")
    end

    it "handles errors" do
      stub_request(:post, "http://www.example.com/almaws/v1/users/janeq/requests?user_id_type=all_unique&mms_id=9936550118202486&allow_same_request=false&apikey=fakeuserkey456")
        .to_raise(RestClient::Exception.new(File.read(File.join(fixture_path, 'request_exists.json')), 400))
      post hold_requests_path, params: { hold_request: valid_attributes.merge({ hold_request: { mms_id: "steamed hams" } }) }
      expect(response).to render_template(:new)
      expect(flash[:error]).to be_present
      expect(flash[:error]).to eq "Failed to save the request: Patron has active request for selected item"
    end
  end

  context "as an unauthenticated user" do
    it "redirects to login select if not logged in" do
      get new_hold_request_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
