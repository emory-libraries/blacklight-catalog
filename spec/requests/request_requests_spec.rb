# frozen_string_literal: true
require 'rails_helper'

WebMock.allow_net_connect!

RSpec.describe 'Requests', type: :request, alma: true do
  let(:user) do
    User.create(
      provider: 'shibboleth',
      uid: 'brianbboys1967',
      display_name: 'Brian Wilson'
    )
  end

  before do
    login_as user
  end

  it "can run a test" do
    # test object: 9937241630902486 Unwitting street

    get requests_path, :params => { :request => { :mms_id => "9937241630902486" } }
    expect(response).to be_successful
    expect(response.body).to include(user.uid)
    expect(response.body).to include("22445410470002486") # Include holding ID for our test object
    expect(response.body).to include("UNIV") # Include holding Library for our test object
  end
end
