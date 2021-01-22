# frozen_string_literal: true
require 'rails_helper'
require 'nokogiri'

RSpec.describe AlmaAvailabilityService do
  let(:id) { '990005988630302486' }
  let(:id2) { '990005059530302486' }
  let(:service) { described_class.new(id) }
  let(:service2) { described_class.new(id2) }

  describe '#current_availability' do
    it 'returns the correct response #1' do
      expect(service.current_availability).to eq(
        { "990005988630302486" => { online: { exists: true }, physical: { available: true, exists: true } } }
      )
    end

    it 'returns the correct response #2' do
      expect(service2.current_availability).to eq(
        { "990005059530302486" => { online: { exists: false }, physical: { available: true, exists: true } } }
      )
    end
  end
end
