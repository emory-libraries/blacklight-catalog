# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SolrCacheEntry, type: :model do
  it 'validates correctly formatter entries' do
    entry = described_class.new(key: '{}', value: '{}', expiration_time: DateTime.now + 2.hours)
    expect(entry.valid?).to be true
  end

  it "validates the presence of key" do
    entry = described_class.new(value: '{}', expiration_time: DateTime.now + 2.hours)
    expect(entry.valid?).to be false
  end

  it "validates the presence of value" do
    entry = described_class.new(key: 'key', expiration_time: DateTime.now + 2.hours)
    expect(entry.valid?).to be false
  end

  it "validates the presence of expiration time" do
    entry = described_class.new(key: 'key', value: '{}')
    expect(entry.valid?).to be false
  end
end
