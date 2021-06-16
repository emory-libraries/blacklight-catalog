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
    expect(helper.alma_social_login_url).to eq("https://example.alma.exlibrisgroup.com/view/socialLogin?backUrl=http%3A%2F%2Ftest.host%2Falma%2Fsocial_login_callback&institutionCode=01_Example")
  end
end
