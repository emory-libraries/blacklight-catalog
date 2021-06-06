# frozen_string_literal: true
require "rails_helper"
RSpec.describe "holding request new", type: :request do
  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_BIB_KEY']
    ENV['ALMA_API_URL'] = 'www.example.com'
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_BIB_KEY'] = orig_key
  end
  context "as a logged in user" do
    # before do
    #   delete_all_documents_from_solr
    #   solr = Blacklight.default_index.connection
    #   solr.add([MULTIPLE_HOLDINGS_TEST_ITEM])
    #   solr.commit
    # end
    let(:user) { User.create(uid: "foo") }
    let(:valid_attributes) do
      {
        holding_id: "4567",
        pickup_library: "UNIV"
      }
    end
    before do
      sign_in(user)
    end
    it "renders the new template" do
      get new_holding_requests_path, params: { "holding_id" => "4567" }
      expect(response).to render_template(:new)
      expect(assigns(:holding_request).holding_id).to eq "4567"
    end

    xit "can create a holding request" do
      post holding_requests_path, params: { holding_request: valid_attributes }
      expect(response).to redirect_to(holding_requests_path)
    end
  end

  context "as an unauthenticated user" do
    it "redirects to login select if not logged in" do
      get new_holding_requests_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
