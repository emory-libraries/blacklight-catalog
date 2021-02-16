# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'
require 'traject'

RSpec.describe OaiProcessingService do
  let(:process_indexer) do
    described_class.process_oai_with_marc_indexer(
      'blah',
      "?verb=ListRecords&set=blacklight4&metadataPrefix=marc21&until=2021-01-28T19:16:10Z",
      'smackety'
    )
  end

  context '#process_oai_with_marc_indexer' do
    before do
      delete_all_documents_from_solr
      process_indexer
    end

    let(:solr) { Blacklight.default_index.connection }
    let(:response) { solr.get('select') }
    let(:number_of_docs) { response['response']['numFound'] }

    it 'calls the process_oai method' do
      expect(described_class).to respond_to(:process_oai)
    end

    it 'calls the alma api' do
      expect(RestClient).to respond_to(:get).with(1).argument
    end

    it 'calls the Traject command to process the xml' do
      expect(Traject::Indexer::MarcIndexer).to respond_to(:new)
      expect(number_of_docs).to eq 4
    end

    context 'reindexing' do
      context 'ensuring non-duplication' do
        let(:response_ids) { response['response']['docs'].map { |d| d['id'] } }
        let(:ids_array) do
          ["990005651670302486", "990000954720302486", "990028391040302486", "990002589250302486"]
        end

        it 'produces the same unique records when running the indexer on the same material' do
          expect(number_of_docs).to eq 4
          expect(response_ids).to match_array(ids_array)

          process_indexer

          expect(number_of_docs).to eq 4
          expect(response_ids).to match_array(ids_array)
        end
      end
    end
  end
end
