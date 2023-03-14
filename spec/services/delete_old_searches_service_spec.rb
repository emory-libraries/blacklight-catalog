# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DeleteOldSearchesService, :clean do
  around do |example|
    Search.destroy_all
    Search.create(id: 123, query_params: { q: "abc" }, user: nil)
    expect(Search.find(123).query_params).to eq({ "q" => "abc" })
    example.run
    Search.destroy_all
  end

  it 'deletes all searches without user which are a day old or more' do
    Search.update(id: 123, created_at: Time.zone.today - 1 - 1.minute)
    described_class.destroy_searches
    expect(Search.find_by_id(123)).to eq nil
  end

  it 'does not delete searches without user which are less than a day old' do
    Search.update(id: 123, created_at: Time.current - 30.minutes)
    described_class.destroy_searches
    expect(Search.find_by_id(123).nil?).to eq false
  end
end
