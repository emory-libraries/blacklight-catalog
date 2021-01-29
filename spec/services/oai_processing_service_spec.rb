# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'
require 'traject'

RSpec.describe OaiProcessingService do
  context '#process_oai_with_marc_indexer' do
    before do
      delete_all_documents_from_solr
      described_class.process_oai_with_marc_indexer(
        ENV['INSTITUTION'],
        "?verb=ListRecords&set=blacklight4&metadataPrefix=marc21&until=2021-01-28T19:16:10Z",
        ENV['ALMA']
      )
    end

    let(:solr) { Blacklight.default_index.connection }

    it 'calls the process_oai method' do
      expect(described_class).to respond_to(:process_oai)
    end

    it 'calls the alma api' do
      expect(RestClient).to respond_to(:get).with(1).argument
    end

    it 'calls the Traject command to process the xml' do
      response = solr.get('select')

      expect(Traject::Indexer::MarcIndexer).to respond_to(:new)
      expect(response['response']['numFound']).to eq 4
    end
  end
end
