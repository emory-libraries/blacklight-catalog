# frozen_string_literal: true
require 'rails_helper'
require 'nokogiri'

RSpec.describe AlmaAvailabilityService, alma: true do
  let(:id) { '990005988630302486' }
  let(:id2) { '990005059530302486' }
  let(:id3) { '990027507910302486' }
  let(:service) { described_class.new([id]) }
  let(:service2) { described_class.new([id2]) }
  let(:service3) { described_class.new([id, id2]) }
  let(:service4) { described_class.new([id3]) }
  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_BIB_KEY']
    ENV['ALMA_API_URL'] = 'www.example.com'
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_BIB_KEY'] = orig_key
  end

  describe '#availability_of_documents' do
    it 'returns the correct response #1' do
      expect(service.availability_of_documents).to eq(
        { "990005988630302486" =>
          { online_available: false, physical_available: true,
            physical_check_holdings: false, physical_exists: true } }
      )
    end

    it 'returns the correct response #2' do
      expect(service2.availability_of_documents).to eq(
        { "990005059530302486" =>
          { online_available: false, physical_available: true,
            physical_check_holdings: false, physical_exists: true } }
      )
    end

    it 'returns the correct response #3' do
      expect(service3.availability_of_documents).to eq(
        { "990005059530302486" =>
          { online_available: false, physical_available: true,
            physical_check_holdings: false, physical_exists: true },
          "990005988630302486" =>
          { online_available: false, physical_available: true,
            physical_check_holdings: false, physical_exists: true } }
      )
    end

    it 'returns the correct response #4' do
      expect(service4.availability_of_documents).to eq(
        { "990027507910302486" =>
          { online_available: false, physical_available: true,
            physical_check_holdings: true, physical_exists: true } }
      )
    end
  end
end
