# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ExtractGenre do
  let(:logger) { instance_double(Logger, "logger", info: nil, debug: nil) }

  before do
    delete_all_documents_from_solr
    # The command below is processing fixures/alma_marc_resource.xml
    OaiProcessingService.process_oai_with_marc_indexer(
      'blah',
      '?verb=ListRecords&set=blacklight_marc_resource&metadataPrefix=marc21&until=2021-01-28T19:16:10Z',
      'smackety',
      false,
      logger
    )
  end

  describe 'field `genre_ssim`' do
    let(:document) { SolrDocument.find('010101010101010101') }

    let(:excluded_elements) do
      [
        "Test Genre II", "Test Genre III"
      ]
    end

    let(:included_elements) do
      [
        "Test Genre I", "Test Genre IV", "Test Local Subject Heading"
      ]
    end

    it 'removes invalid datafields' do
      expect(document['genre_ssim']).not_to include(excluded_elements)
    end

    it 'keeps valid datafields' do
      expect(document['genre_ssim']).to match_array(included_elements)
    end
  end
end
