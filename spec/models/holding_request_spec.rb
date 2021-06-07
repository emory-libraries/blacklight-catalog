# frozen_string_literal: true
require 'rails_helper'

RSpec.describe HoldingRequest do
  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_USER_KEY']
    ENV['ALMA_API_URL'] = 'www.example.com'
    ENV['ALMA_USER_KEY'] = "fakeuserkey456"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_USER_KEY'] = orig_key
  end

  it "has a holding id available" do
    hr = described_class.new(holding_id: "456")
    expect(hr.holding_id).to eq "456"
  end

  it "can persist a holding request to Alma" do
    hr = described_class.new(mms_id: "9936550118202486", holding_id: "22332597410002486", user: "mkadel")
    hr.save
    expect(hr.id).to eq "36181952270002486"
  end

  it "can find an existing holding request in Alma" do
    hr = described_class.find(id: "36181952270002486", user: "mkadel")
    expect(hr.mms_id).to eq "9936550118202486"
  end
end
