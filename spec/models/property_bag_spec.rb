# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PropertyBag, :clean do
  let(:time_ingester_format) { Time.new.utc.strftime("%Y-%m-%dT%H:%M:%SZ") }
  let(:item_name) { 'test_marc_ingest_time' }

  before { described_class.set(item_name, time_ingester_format) }

  context '#set' do
    it 'calls the set method' do
      expect(described_class).to respond_to(:set)
    end

    it 'produces one instance of the class' do
      expect(described_class.count).to eq(1)
    end

    it 'has the expected values' do
      inst = described_class.first

      expect(inst.name).to eq(item_name)
      expect(inst.value).to eq(time_ingester_format)
    end
  end

  context '#get' do
    it 'calls the set method' do
      described_class.get(item_name)
      expect(described_class).to respond_to(:get)
    end

    it 'returns the value set when instance exists' do
      expect(described_class.get(item_name)).to eq(time_ingester_format)
    end

    it 'returns nil when instance does not exist' do
      described_class.first.delete
      expect(described_class.get(item_name)).to be_nil
    end
  end
end
