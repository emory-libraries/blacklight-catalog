# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'
require 'traject'

RSpec.describe OaiProcessingService do
  context '#process_oai_with_marc_indexer' do
    before do
      delete_all_documents_from_solr
      described_class.process_oai_with_marc_indexer(
        'blah',
        "?verb=ListRecords&set=blacklight4&metadataPrefix=marc21&until=2021-01-28T19:16:10Z",
        'smackety'
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

    context 'reindexing' do
      context 'ensuring non-duplication' do
        it 'produces the same unique records when running the indexer on the same material' do
          expect do
            described_class.process_oai_with_marc_indexer('blah',
              "?verb=ListRecords&set=blacklight4&metadataPrefix=marc21&until=2021-01-28T19:16:10Z",
              'smackety')
          end.to change { solr.get('select')['response']['docs'].map { |d| d['_version_'] } }
            .and not_change { solr.get('select')['response']['docs'].map { |d| d['id'] } }
        end
      end
    end
  end
end
