# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Indexing' do
  let(:logger) { instance_double(Logger, "logger", info: nil, debug: nil) }
  let(:solr_doc_1) { SolrDocument.find('9937264718202486') }
  let(:solr_doc_2) { SolrDocument.find('010101010101010101') }
  let(:solr_doc_3) { SolrDocument.find('020202020202020202') }

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

  describe 'field `subject_display_ssim`' do
    let(:excluded_elements) do
      [
        "Economic history.", "Ethnic groups.", "Ethnology.", "Population.", "Population density.",
        "Rain and rainfall.", "Religion.", "Tribes.", "Yemen (Republic)"
      ]
    end
    let(:included_elements) do
      [
        "Population density--Yemen (Republic)--Maps", "Ethnic groups--Yemen (Republic)--Maps",
        "Tribes--Yemen (Republic)--Maps", "Ethnology--Yemen (Republic)--Maps", "Rain and rainfall--Yemen (Republic)--Maps",
        "Land use--Yemen (Republic)--Maps", "Yemen (Republic)--Maps", "Yemen (Republic)--Population--Maps",
        "Yemen (Republic)--Economic conditions--Maps", "Yemen (Republic)--Religion--Maps"
      ]
    end

    it 'removes datafields with indicator_2 = 4 or subfields with code = 2 and value - fast' do
      expect(solr_doc_1['subject_display_ssim']).not_to include(excluded_elements)
    end

    it('keeps the rest') { expect(solr_doc_1['subject_display_ssim']).to match_array(included_elements) }

    context 'when harmful language is present' do
      it 'replaces harmful terms' do
        expect(solr_doc_3['subject_display_ssim']).to match_array(["Gender dysphoria"])
      end
    end
  end

  describe 'field `subject_ssim`' do
    let(:excluded_elements) do
      [
        "Test subject II", "Test subject III"
      ]
    end

    let(:included_elements) do
      [
        "Test subject I", "Test subject IV"
      ]
    end

    it 'removes invalid datafields' do
      expect(solr_doc_2['subject_ssim']).not_to include(excluded_elements)
    end

    it 'keeps valid datafields' do
      expect(solr_doc_2['subject_ssim']).to match_array(included_elements)
    end

    context 'when harmful language is present' do
      it 'replaces harmful terms' do
        expect(solr_doc_3['subject_ssim']).to match_array(["Gender dysphoria"])
      end
    end
  end

  describe 'field `subject_tesim`' do
    context 'when harmful language is present' do
      it 'appends new terms' do
        expect(solr_doc_3['subject_tesim']).to match_array(["Gender identity disorder.", "Gender dysphoria."])
      end
    end
  end
end
