# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OaiQueryStringService, :clean do
  let(:oai_set) { 'blacklighttest' }
  let(:full_index) { false }
  let(:single_record) { true }
  let(:to_time) { Time.new.utc.strftime("%Y-%m-%dT%H:%M:%SZ") }
  let(:ingest_time) { '2021-02-23T21:32:25Z' }
  let(:institution) { ENV['INSTITUTION'] }
  PropertyBag.set('marc_ingest_resumption_token', '')

  before { PropertyBag.set('marc_ingest_time', ingest_time) }
  after { PropertyBag.delete_all }

  context '#process_query_string' do
    it 'returns the right string when full_index false and resumption token not present and single_record true' do
      qs = described_class.process_query_string(oai_set, full_index, to_time, single_record)

      check_other_methods_called
      expect(qs).to eq(
        "?verb=GetRecord&identifier=oai:alma.#{institution}:#{oai_set}&metadataPrefix=marc21"
      )
    end

    it 'returns the right string when full_index false and resumption token not present' do
      qs = described_class.process_query_string(oai_set, full_index, to_time, false)

      check_other_methods_called
      expect(qs).to eq(
        "?verb=ListRecords&set=#{oai_set}&metadataPrefix=marc21&until=#{to_time}&from=#{ingest_time}"
      )
    end

    it 'returns the right string when full_index true and resumption token not present' do
      qs = described_class.process_query_string(oai_set, true, to_time, false)

      check_other_methods_called
      expect(qs).to eq(
        "?verb=ListRecords&set=#{oai_set}&metadataPrefix=marc21&until=#{to_time}"
      )
    end

    it 'returns the right string when resumption token present' do
      PropertyBag.set('marc_ingest_resumption_token', 'Hello!')
      qs = described_class.process_query_string(oai_set, full_index, to_time, false)

      check_other_methods_called
      expect(qs).to eq("?verb=ListRecords&resumptionToken=Hello!")
    end
  end

  context '#process_from_time' do
    it 'returns ingest_time inside a substring when full_index is false' do
      expect(described_class.process_from_time(full_index)).to eq("&from=#{ingest_time}")
    end

    it 'returns nothing when full_index is true' do
      expect(described_class.process_from_time(true)).to be_nil
    end
  end

  def check_other_methods_called
    expect(described_class).to respond_to(:process_from_time).with(1).argument
    expect(described_class).to respond_to(:process_string).with(5).argument
  end
end
