# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do
  around do |example|
    ENV['ALMA'] = 'example'
    ENV['INSTITUTION'] = '01_Example'
    example.run
    ENV['ALMA'] = ''
    ENV['INSTITUTION'] = ''
  end
  it 'builds correct url' do
    url = "https://example.alma.exlibrisgroup.com/view/socialLogin?backUrl="\
    "http%3A%2F%2Ftest.host%2Falma%2Fsocial_login_callback%3F"\
    "redirect_to%3Dhttp%253A%252F%252Flocalhost%253A3000%252Fcatalog%252F990011434390302486"\
    "&institutionCode=01_Example"
    expect(helper.alma_social_login_url(redirect_to: "http://localhost:3000/catalog/990011434390302486")).to eq(url)
  end
end
