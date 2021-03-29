# frozen_string_literal: true
require 'rails_helper'
require 'rest-client'
require 'nokogiri'
require 'traject'

RSpec.describe OaiProcessingSingleService do
  context '#process_oai_with_marc_indexer' do
    before do
      delete_all_documents_from_solr
      # The command below is processing one record
      described_class.process_oai_with_marc_indexer(
        'blah',
        "?verb=GetRecord&identifier=oai:alma.blah:single_record&metadataPrefix=marc21",
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
      expect(solr_num_of_docs).to eq 1
    end

    context 'reindexing' do
      context 'ensuring non-duplication' do
        it 'produces the same unique records when running the indexer on the same material' do
          expect do
            # The command below is processing one record
            described_class.process_oai_with_marc_indexer('blah',
              "?verb=GetRecord&identifier=oai:alma.blah:single_record&metadataPrefix=marc21",
              'smackety')
          end.to change { solr_docs_map_of('_version_') }.and not_change { solr_docs_map_of('id') }
        end
      end

      context 'ensuring fields delete' do
        it 'removes field when data needed to index is missing' do
          expect do
            # The command below is processing 990000954720302486
            described_class.process_oai_with_marc_indexer('blah',
              "?verb=GetRecord&identifier=oai:alma.blah:single_record_missing&metadataPrefix=marc21",
              'smackety')
          end.to change { solr_docs_count_of('lccn_ssim') }.from(1).to(0)
        end
      end

      context 'updating fields with different data' do
        it 'updates 1 field when data changed and adds 1 to index when new data introduced' do
          expect do
            # The command below is processing 990000954720302486
            described_class.process_oai_with_marc_indexer('blah',
              "?verb=GetRecord&identifier=oai:alma.blah:single_record_updated&metadataPrefix=marc21",
              'smackety')
          end.to change { solr_field_value_for('990000954720302486', 'material_type_display_tesim') }
            .from(['34 pages ; 26 cm.']).to(['44 pages ; 26 cm.'])
        end
      end
    end

    context 'deleted and suppressed records', :clean do
      it 'checks for presence of a record before running the deleted records OAI and then checks for absence' do
        # first we make sure record with this ID exists after first run. This record will later be suppressed.
        expect(solr_docs_map_of('id')).to include("990000954720302486")
        # we then run indexer with the oai that has deleted and suppressed records info (alma_deleted_and_suppressed_records.xml)
        described_class.process_oai_with_marc_indexer(
          'blah',
          "?verb=GetRecord&identifier=oai:alma.blah:single_record_deleted&metadataPrefix=marc21",
          'smackety'
        )
        expect(solr_docs_map_of('id')).not_to include("990000954720302486") # making sure second suppressed record ID is not present in SOLR
        expect(solr_num_of_docs).to eq 0
      end
    end

    def solr_docs_map_of(field_name)
      solr_response['docs'].map { |d| d[field_name] }
    end

    def solr_docs_count_of(field_name)
      solr_docs_map_of(field_name).compact.size
    end

    def solr_num_of_docs
      solr_response['numFound']
    end

    def solr_response
      solr.get('select')['response']
    end

    def solr_field_value_for(id, field_name)
      SolrDocument.find(id)[field_name]
    end
  end
end
