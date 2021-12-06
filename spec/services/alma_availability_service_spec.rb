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
          { online_available: false, physical_holdings: [
            { call_number: "PT2613 .M45 Z92 2006", lib_location: "",
              library: "Library Service Center", status: "available" }
          ] } }
      )
    end

    it 'returns the correct response #2' do
      expect(service2.availability_of_documents).to eq(
        { "990005059530302486" =>
          { online_available: false, physical_holdings: [
            { call_number: "PS3505 .R43 H4 1976 DANOWSKI", lib_location: "Locked Stacks",
              library: "Stuart A. Rose Manuscript, Archives, and Rare Book Library",
              status: "available" },
            { call_number: "PS3505 .R43 H4 1976 EDELSTEIN", lib_location: "Locked Stacks",
              library: "Stuart A. Rose Manuscript, Archives, and Rare Book Library", status: "available" }
          ] } }
      )
    end

    it 'returns the correct response #3' do
      expect(service3.availability_of_documents).to eq(
        { "990005059530302486" =>
          { online_available: false, physical_holdings: [
            { call_number: "PS3505 .R43 H4 1976 DANOWSKI", lib_location: "Locked Stacks",
              library: "Stuart A. Rose Manuscript, Archives, and Rare Book Library",
              status: "available" },
            { call_number: "PS3505 .R43 H4 1976 EDELSTEIN", lib_location: "Locked Stacks",
              library: "Stuart A. Rose Manuscript, Archives, and Rare Book Library",
              status: "available" }
          ] },
          "990005988630302486" =>
          { online_available: false, physical_holdings: [
            { call_number: "PT2613 .M45 Z92 2006", lib_location: "",
              library: "Library Service Center", status: "available" }
          ] } }
      )
    end

    it 'returns the correct response #4' do
      expect(service4.availability_of_documents).to eq(
        { "990027507910302486" =>
          { online_available: false, physical_holdings: [
            { call_number: "JA1 .R4", lib_location: "", library: "Library Service Center",
              status: "available" },
            { call_number: "JA1 .R4", lib_location: "Book Stacks", library: "Robert W. Woodruff Library",
              status: "available" },
            { call_number: "JA1 .R4", lib_location: "Current Periodicals", library: "Robert W. Woodruff Library",
              status: "check_holdings" }
          ] } }
      )
    end
  end
end
