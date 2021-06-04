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
  context "logged in user makes new request" do
    before do
      sign_in(User.new(uid: "foo"))
    end
    it "render the new template" do
      get new_holding_requests_path, params: { "mms_id" => "abc" }
      expect(response).to render_template(:new)
      expect(assigns(:holding_request).mms_id).to eq "abc"
    end
  end
  context "with a holding w/ more than one location" do
    before do
      delete_all_documents_from_solr
      solr = Blacklight.default_index.connection
      solr.add([MULTIPLE_HOLDINGS_TEST_ITEM])
      solr.commit
    end
    it "redirects to login select if not logged in" do
      get new_holding_requests_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
