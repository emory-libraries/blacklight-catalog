require "rails_helper"

RSpec.describe "holding request new" , :type=> :request do
  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_BIB_KEY']
    ENV['ALMA_API_URL'] = 'www.example.com'
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_BIB_KEY'] = orig_key
  end
  context "when user logged in via shib" do
  before do
    User.create(
      provider: 'shibboleth',
      uid: 'brianbboys1967',
      display_name: 'Brian Wilson'
    )
  OmniAuth.config.mock_auth[:shib] =
    OmniAuth::AuthHash.new(
      provider: 'shibboleth',
      uid: "P0000001",
      info: {
        display_name: "Brian Wilson",
        uid: 'brianbboys1967'
      }
    )
  end
    it "should redirect to login select if not logged in" do
      get new_holding_requests_path
      expect(response).to render_template("new")
    end
  end
  context "with a holding w/ more than one location" do
    before do
      delete_all_documents_from_solr
      solr = Blacklight.default_index.connection
      solr.add([MULTIPLE_HOLDINGS_TEST_ITEM])
      solr.commit
    end
    it "should redirect to login select if not logged in" do
      get new_holding_requests_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

end

RSpec.describe "Request a holding", :type => :system, js: true do
  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_BIB_KEY']
    ENV['ALMA_API_URL'] = 'www.example.com'
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_BIB_KEY'] = orig_key
  end
  context "with a holding w/ more than one location" do
    before do
      delete_all_documents_from_solr
      solr = Blacklight.default_index.connection
      solr.add([MULTIPLE_HOLDINGS_TEST_ITEM])
      solr.commit
    end
    it "shows a request button on the holding" do
      visit "/catalog/9937004854502486"
      within "#physical-holding-1" do
        expect(page).to have_button("Request")
      end
      within "#physical-holding-2" do
        expect(page).to have_button("Request")
        click_button("Request")
      end
      expect("page").to have_text "Select your Login Mode"
    end
  end
end
