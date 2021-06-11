# frozen_string_literal: true
require "rails_helper"
RSpec.describe "holding request new", type: :request do
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
        "holding_id": "22332597410002486",
        "pickup_library": "MUSME",
        "comment": "IGNORE - TESTING",
        "not_needed_after(1i)": "2021",
        "not_needed_after(2i)": "6",
        "not_needed_after(3i)": "10"
      }
    end
    before do
      sign_in(user)
    end
    it "renders the new template" do
      get new_holding_request_path, params: { "holding_id" => "4567", holding_library: { "label" => "Oxford College Library", "value" => "OXFD" },
                                              holding_location: { label: "Media Collection", value: "MEDIA" } }
      expect(response).to render_template(:new)
      expect(assigns(:holding_request).holding_id).to eq "4567"
      expect(assigns(:holding_request).holding_library).to eq({ label: "Oxford College Library", value: "OXFD" })
      expect(assigns(:holding_request).holding_location).to eq({ label: "Media Collection", value: "MEDIA" })
    end

    it "renders the new template and translates the date to a string" do
      get new_holding_request_path, params: { "not_needed_after" => "2021-06-10Z" }
      expect(response).to render_template(:new)
      expect(assigns(:holding_request).not_needed_after).to eq "2021-06-10Z"
    end

    it "can create a holding request" do
      post holding_requests_path, params: { holding_request: valid_attributes }
      expect(assigns(:holding_request).not_needed_after).to eq "2021-06-10Z"
      expect(response).to redirect_to(holding_request_path("36181952270002486"))
      follow_redirect!
      expect(response).to render_template(:show)
      expect(response.body).to include("36181952270002486")
      expect(response.body).to include("MUSME")
      expect(response.body).to include("IGNORE - TESTING")
    end

    it "renders a successful response" do
      get holding_request_path("36181952270002486")
      expect(response).to be_successful
      expect(response).to render_template(:show)
      expect(response.body).to include("36181952270002486")
      expect(response.body).to include("MUSME")
      expect(response.body).to include("IGNORE - TESTING")
    end
  end

  context "as an unauthenticated user" do
    it "redirects to login select if not logged in" do
      get new_holding_request_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
