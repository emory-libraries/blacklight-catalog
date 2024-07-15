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
  let(:service5) { described_class.new(['9937864299502486']) }
  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_BIB_KEY']
    orig_alma = ENV['ALMA']
    orig_inst = ENV["INSTITUTION"]
    ENV['ALMA'] = 'emory-alma'
    ENV['ALMA_API_URL'] = 'www.example.com'
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    ENV["INSTITUTION"] = 'EMORY'
    example.run
    ENV['ALMA'] = orig_alma
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_BIB_KEY'] = orig_key
    ENV["INSTITUTION"] = orig_inst
  end

  describe '#availability_of_documents' do
    it 'returns the correct response for one physical holding' do
      expect(service.availability_of_documents).to eq(
        { "990005988630302486" =>
          { online_available: false, physical_holdings: [
            { call_number: "PT2613 .M45 Z92 2006", lib_location: "Book Stacks",
              library: "Robert W. Woodruff Library", status: "available" }
          ] } }
      )
    end

    it 'returns the correct response for multiple physical holdings' do
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

    it 'returns the correct response for multiple records' do
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
            { call_number: "PT2613 .M45 Z92 2006", lib_location: "Book Stacks",
              library: "Robert W. Woodruff Library", status: "available" }
          ] } }
      )
    end

    it 'returns the correct response for multiple types of physical holdings' do
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

    it 'returns the correct response for one online holding' do
      expect(service5.availability_of_documents).to eq(
        { "9937864299502486" =>
          { online_available: true, physical_holdings: [] } }
      )
    end
  end
end
