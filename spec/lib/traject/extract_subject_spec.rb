# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ExtractSubject do
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

  describe 'field `subject_display_ssim`' do
    let(:document) { SolrDocument.find('9937264718202486') }

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
      expect(document['subject_display_ssim']).not_to include(excluded_elements)
    end

    it('keeps the rest') { expect(document['subject_display_ssim']).to match_array(included_elements) }

    context 'when harmful language is present' do
      let(:document) { SolrDocument.find('020202020202020202') }

      it 'replaces harmful terms' do
        expect(document['subject_display_ssim']).to match_array(["Gender dysphoria"])
      end
    end
  end

  describe 'field `subject_ssim`' do
    let(:document) { SolrDocument.find('010101010101010101') }

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
      expect(document['subject_ssim']).not_to include(excluded_elements)
    end

    it 'keeps valid datafields' do
      expect(document['subject_ssim']).to match_array(included_elements)
    end

    context 'when harmful language is present' do
      let(:document) { SolrDocument.find('020202020202020202') }

      it 'replaces harmful terms' do
        expect(document['subject_ssim']).to match_array(["Gender dysphoria"])
      end
    end
  end

  describe 'field `subject_tesim`' do
    let(:document) { SolrDocument.find('020202020202020202') }

    context 'when harmful language is present' do
      it 'appends new terms' do
        expect(document['subject_tesim']).to match_array(["Gender identity disorder.", "Gender dysphoria."])
      end
    end

    context 'when a local subject heading is present' do
      let(:document) { SolrDocument.find('010101010101010101') }

      it 'extracts the local heading' do
        expect(document['subject_tesim']).to include("Test Local Subject Heading")
      end
    end
  end

  describe 'subject_era_ssim field' do
    let(:document) { SolrDocument.find('010101010101010101') }

    let(:excluded_elements) do
      [
        "20th Century Test I", "20th Century Test II"
      ]
    end
    let(:included_elements) do
      [
        "20th Century", "20th Century Test III"
      ]
    end

    it 'removes invalid datafields' do
      expect(document['subject_era_ssim']).not_to include(excluded_elements)
    end

    it 'keeps valid datafields' do
      expect(document['subject_era_ssim']).to match_array(included_elements)
    end
  end

  describe 'subject_geo_ssim field' do
    let(:document) { SolrDocument.find('010101010101010101') }

    let(:excluded_elements) do
      [
        "United States II", "United States III"
      ]
    end

    let(:included_elements) do
      [
        "United States I", "United States IV"
      ]
    end

    it 'removes invalid datafields' do
      expect(document['subject_geo_ssim']).not_to include(excluded_elements)
    end

    it 'keeps valid datafields' do
      expect(document['subject_geo_ssim']).to match_array(included_elements)
    end
  end
end
