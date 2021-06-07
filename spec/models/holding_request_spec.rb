# frozen_string_literal: true
require 'rails_helper'

RSpec.describe HoldingRequest do
  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_BIB_KEY']
    ENV['ALMA_API_URL'] = 'www.example.com'
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_BIB_KEY'] = orig_key
  end

  it "has a holding id available" do
    hr = described_class.new(holding_id: "456")
    expect(hr.holding_id).to eq "456"
  end
end
