# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Indexing fields with custom logic' do
  before do
    delete_all_documents_from_solr
    OaiProcessingService.process_oai_with_marc_indexer(
      'blah',
      "?verb=ListRecords&set=blacklight_marc_resource&metadataPrefix=marc21&until=2021-01-28T19:16:10Z",
      'smackety'
    )
  end

  describe 'marc_resource_ssim field, when no 997 or 998 fields' do
    context 'and 000/6 == e, f, g, k, o, or r and 008/29 == o or s' do
      let(:solr_doc) { SolrDocument.find('9937264718402486') }

      it 'is mapped with Electronic Resource' do
        expect(solr_doc['marc_resource_ssim']).to eq(['Electronic Resource'])
      end
    end

    context 'and 000/6 == e, f, g, k, o, or r and 008/29 != o or s' do
      let(:solr_doc) { SolrDocument.find('9937264718202486') }

      it 'is mapped with Physical Resource' do
        expect(solr_doc['marc_resource_ssim']).to eq(['Physical Resource'])
      end
    end

    context 'and 000/6 != e, f, g, k, o, or r and 008/29 == o or s' do
      let(:solr_doc) { SolrDocument.find('9937264717902486') }

      it 'is mapped with Electronic Resource' do
        expect(solr_doc['marc_resource_ssim']).to eq(['Electronic Resource'])
      end
    end

    context 'and 000/6 != e, f, g, k, o, or r and 008/29 != o or s' do
      let(:solr_doc) { SolrDocument.find('9937264718102486') }

      it 'is mapped with Physical Resource' do
        expect(solr_doc['marc_resource_ssim']).to eq(['Physical Resource'])
      end
    end
  end

  describe 'format_ssim field' do
    context 'when leader 6 and 7 positions is am' do
      let(:solr_doc) { SolrDocument.find('9937264717902486') }

      it 'is mapped as a Book' do
        expect(solr_doc['format_ssim']).to eq(["Book"])
      end
    end

    context 'when leader 6 is e' do
      let(:solr_doc) { SolrDocument.find('9937264718202486') }

      it 'is mapped as a Map' do
        expect(solr_doc['format_ssim']).to eq(["Map"])
      end
    end
  end
end
