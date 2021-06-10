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
        user: user,
        mms_id: "9936550118202486",
        holding_id: "22332597410002486",
        pickup_library: "MUSME"
      }
    end
    before do
      sign_in(user)
    end
    it "renders the new template" do
      get new_holding_request_path, params: { "holding_id" => "4567", holding_library: { "label" => "Oxford College Library", "value" => "OXFD" } }
      expect(response).to render_template(:new)
      expect(assigns(:holding_request).holding_id).to eq "4567"
      expect(assigns(:holding_request).holding_library).to eq({ label: "Oxford College Library", value: "OXFD" })
    end

    it "can create a holding request" do
      post holding_requests_path, params: { holding_request: valid_attributes }
      expect(response).to redirect_to(holding_request_path("36181952270002486"))
      follow_redirect!
      expect(response).to render_template(:show)
      expect(response.body).to include("36181952270002486")
      expect(response.body).to include("MUSME")
    end

    it "renders a successful response" do
      get holding_request_path("36181952270002486")
      expect(response).to be_successful
      expect(response).to render_template(:show)
      expect(response.body).to include("36181952270002486")
      expect(response.body).to include("MUSME")
    end
  end

  context "as an unauthenticated user" do
    it "redirects to login select if not logged in" do
      get new_holding_request_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
