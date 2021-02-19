# frozen_string_literal: true
require 'rails_helper'
require 'rest-client'
require 'nokogiri'
require 'traject'

RSpec.describe OaiProcessingService do
  context '#process_oai_with_marc_indexer' do
    before do
      delete_all_documents_from_solr
      # The command below is processing fixures/alma_small_set.xml
      described_class.process_oai_with_marc_indexer(
        'blah',
        "?verb=ListRecords&set=blacklight4&metadataPrefix=marc21&until=2021-01-28T19:16:10Z",
        'smackety'
      )
    end

    around do |example|
      ENV['SOLR_URL'] = "http://127.0.0.1:8985/solr/blacklight-test"
      example.run
      ENV['SOLR_URL'] = ""
    end

    let(:solr) { Blacklight.default_index.connection }

    it 'calls the process_oai method' do
      expect(described_class).to respond_to(:process_oai)
    end

    it 'calls the alma api' do
      expect(RestClient).to respond_to(:get).with(1).argument
    end

    it 'calls the Traject command to process the xml' do
      expect(Traject::Indexer::MarcIndexer).to respond_to(:new)
      expect(solr.get('select')['response']['numFound']).to eq 4
    end

    context 'reindexing' do
      context 'ensuring non-duplication' do
        it 'produces the same unique records when running the indexer on the same material' do
          expect do
            # The command below is processing fixures/alma_small_set.xml
            described_class.process_oai_with_marc_indexer('blah',
              "?verb=ListRecords&set=blacklight4&metadataPrefix=marc21&until=2021-01-28T19:16:10Z",
              'smackety')
          end.to change { solr_docs_map_of('_version_') }.and not_change { solr_docs_map_of('id') }
        end
      end

      context 'ensuring fields delete' do
        it 'removes field when data needed to index is missing' do
          expect do
            # The command below is processing fixures/alma_small_set_with_2_fields_missing.xml
            described_class.process_oai_with_marc_indexer('blah',
              "?verb=ListRecords&set=blacklight4&metadataPrefix=marc21&until=2021-02-15T19:16:10Z",
              'smackety')
          end.to change { solr_docs_count_of('material_type_display_tesim') }
            .from(3).to(2)
            .and change { solr_docs_count_of('lccn_ssim') }.from(2).to(1)
        end
      end
    end

    context 'deleted and suppressed records', :clean do
      it 'checks for presence of a record before running the deleted records OAI and then checks for absence' do
        # first we make sure record with this ID exists after first run. This record will later be suppressed.
        expect(solr_docs_map_of('id')).to include("990005651670302486")
        # first we make sure record with this ID exists after first run. This record will later be deleted.
        expect(solr_docs_map_of('id')).to include("990000954720302486")
        # we then run indexer with the oai that has deleted and suppressed records info (alma_deleted_and_suppressed_records.xml)
        described_class.process_oai_with_marc_indexer(
          'blah',
          "?verb=ListRecords&set=blacklight4&metadataPrefix=marc21&until=2021-01-29T19:16:10Z",
          'smackety'
        )
        expect(solr_docs_map_of('id')).not_to include("990005651670302486") # making sure suppressed record ID is not present in SOLR
        expect(solr_docs_map_of('id')).not_to include("990000954720302486") # making sure ID under deleted status header is not present in SOLR
        expect(solr.get('select')['response']['numFound']).to eq 2
      end
    end

    def solr_docs_map_of(field_name)
      solr.get('select')['response']['docs'].map { |d| d[field_name] }
    end

    def solr_docs_count_of(field_name)
      solr_docs_map_of(field_name).compact.size
    end
  end
end
