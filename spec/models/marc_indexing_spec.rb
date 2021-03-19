# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Indexing fields with custom logic' do
  before do
    delete_all_documents_from_solr
    # The command below is processing fixures/alma_marc_resource.xml
    OaiProcessingService.process_oai_with_marc_indexer(
      'blah',
      '?verb=ListRecords&set=blacklight_marc_resource&metadataPrefix=marc21&until=2021-01-28T19:16:10Z',
      'smackety'
    )
  end

  describe 'marc_resource_ssim field, when 598a equals "NEW"' do
    let(:solr_doc) { SolrDocument.find('9937264718402486') }

    it 'is mapped with Recently Acquired' do
      expect(solr_doc['marc_resource_ssim']).to include('Recently Acquired')
    end
  end

  describe 'marc_resource_ssim field, when 598a does not exist' do
    let(:solr_doc) { SolrDocument.find('9937264718202486') }
    let(:solr_doc_2) { SolrDocument.find('9937264717902486') }
    let(:solr_doc_3) { SolrDocument.find('9937264718102486') }

    it 'is not mapped with Recently Acquired' do
      [solr_doc, solr_doc_2, solr_doc_3].each do |d|
        expect(d['marc_resource_ssim']).not_to include('Recently Acquired')
      end
    end
  end

  describe 'marc_resource_ssim field, when no 997 or 998 fields' do
    context 'and 000/6 == e, f, g, k, o, or r and 008/29 == o or s' do
      let(:solr_doc) { SolrDocument.find('9937264718402486') }

      it 'is mapped with Online' do
        expect(solr_doc['marc_resource_ssim']).to include('Online')
      end
    end

    context 'and 000/6 == e, f, g, k, o, or r and 008/29 != o or s' do
      let(:solr_doc) { SolrDocument.find('9937264718202486') }

      it 'is mapped with At the Library' do
        expect(solr_doc['marc_resource_ssim']).to eq(['At the Library'])
      end
    end

    context 'and 000/6 != e, f, g, k, o, or r and 008/29 == o or s' do
      let(:solr_doc) { SolrDocument.find('9937264717902486') }

      it 'is mapped with Online' do
        expect(solr_doc['marc_resource_ssim']).to eq(['Online'])
      end
    end

    context 'and 000/6 != e, f, g, k, o, or r and 008/29 != o or s' do
      let(:solr_doc) { SolrDocument.find('9937264718102486') }

      it 'is mapped with At the Library' do
        expect(solr_doc['marc_resource_ssim']).to eq(['At the Library'])
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

  describe 'publication_main_dispaly_ssm field' do
    let(:solr_doc) { SolrDocument.find('9937264718202486') }

    it 'maps 260, 264, and 008 fields' do
      expect(solr_doc['publication_main_display_ssim']).to eq(["[Washington, D.C.] : [Central Intelligence Agency], [2002]"])
    end
  end

  describe 'title_details_display_tesim field' do
    let(:solr_doc) { SolrDocument.find('9937264718202486') }

    it 'maps 245abp' do
      expect(solr_doc['title_details_display_tesim']).to eq(["Physical Map Test"])
    end
  end

  describe 'publisher_details_dispaly_ssm field' do
    let(:solr_doc) { SolrDocument.find('9937264718202486') }

    it 'maps 260, 264, and 008 fields' do
      expect(solr_doc['publisher_details_display_ssim']).to eq([" Central Intelligence Agency,  Washington, D.C. xx#"])
    end
  end

  describe 'title_main_display_tesim field' do
    let(:solr_doc) { SolrDocument.find('9937264718202486') }

    it 'maps 245abnp' do
      expect(solr_doc['title_main_display_tesim']).to eq(["Physical Map Test"])
    end
  end

  describe 'lc_1letter_ssim field' do
    let(:solr_doc) { SolrDocument.find('9937264718102486') }
    let(:solr_doc_2) { SolrDocument.find('9937264717902486') }
    let(:solr_doc_3) { SolrDocument.find('9937264718202486') }
    let(:solr_doc_4) { SolrDocument.find('9937264718402486') }

    it 'maps P - Language & Literature' do
      [solr_doc, solr_doc_2].each do |s|
        expect(s['lc_1letter_ssim']).to eq(['P - Language & Literature'])
      end
    end

    it 'does not map values when 050a and 090a are empty' do
      [solr_doc_3, solr_doc_4].each do |s|
        expect(s['lc_1letter_ssim']).to be_nil
      end
    end
  end

  describe 'library_ssim field' do
    let(:solr_doc) { SolrDocument.find('9937264718402486') }

    it 'maps HOL852b' do
      expect(solr_doc['library_ssim']).to eq(['UNIV'])
    end
  end

  describe 'collection_ssim field' do
    let(:solr_doc) { SolrDocument.find('9937264718402486') }
    let(:solr_doc_2) { SolrDocument.find('9937264718202486') }
    let(:solr_doc_3) { SolrDocument.find('9937264718102486') }
    let(:solr_doc_4) { SolrDocument.find('9937264717902486') }

    it 'maps 710 indicator1 == 2, subfield == GEU first' do
      expect(solr_doc['collection_ssim']).to eq(
        ['Raymond Danowski Poetry Library (Emory University. General Libraries)']
      )
    end

    it 'maps 490a when exact 710(s) are not found' do
      expect(solr_doc_2['collection_ssim']).to eq(['Open-file report ;'])
    end

    it 'maps 490a when it is the only field available' do
      expect(solr_doc_3['collection_ssim']).to eq(['Bonibooks'])
    end

    it 'maps nothing when neither field available' do
      expect(solr_doc_4['collection_ssim']).to be_nil
    end
  end

  describe 'subject_display_ssim field' do
    let(:solr_doc) { SolrDocument.find('9937264718202486') }
    let(:excluded_elements) do
      [
        "Population density Yemen (Republic) Maps", "Ethnic groups Yemen (Republic) Maps",
        "Tribes Yemen (Republic) Maps", "Ethnology Yemen (Republic) Maps", "Rain and rainfall Yemen (Republic) Maps",
        "Land use Yemen (Republic) Maps", "Economic history", "Ethnic groups", "Ethnology",
        "Population", "Population density", "Rain and rainfall", "Religion", "Tribes"
      ]
    end
    let(:included_elements) do
      [
        "Yemen (Republic) Maps.", "Yemen (Republic) Population Maps.",
        "Yemen (Republic) Economic conditions Maps.", "Yemen (Republic) Religion Maps.",
        "Yemen (Republic)"
      ]
    end

    it 'removes datafields with indicator_2 = 4 or subfields with code = 2 and value - fast' do
      expect(solr_doc['subject_display_ssim']).not_to include(excluded_elements)
    end

    it 'keeps the rest' do
      expect(solr_doc['subject_display_ssim']).to match_array(included_elements)
    end
  end

  describe 'url_fulltext_linktext_ssm field' do
    context "when 856 3 and z are present" do
      let(:solr_doc) { SolrDocument.find('9937264718402486') }

      it 'has value of 856 3 since it has higher precedence than z' do
        expect(solr_doc['url_fulltext_linktext_ssm']).to eq(['Subfield code 3'])
      end
    end

    context "when 856 y, 3, and z are present" do
      let(:solr_doc) { SolrDocument.find('9937264718202486') }

      it 'has value of 856 y since it has higher precedence than 3 and z' do
        expect(solr_doc['url_fulltext_linktext_ssm']).to eq(['Subfield code y'])
      end
    end

    context "when only 856 z is present" do
      let(:solr_doc) { SolrDocument.find('9937264718102486') }

      it 'has value of 856 z' do
        expect(solr_doc['url_fulltext_linktext_ssm']).to eq(['Subfield code z'])
      end
    end

    context "when 856 y and z are present" do
      let(:solr_doc) { SolrDocument.find('9937264717902486') }

      it 'has value of 856 y since it has higher precedence than z' do
        expect(solr_doc['url_fulltext_linktext_ssm']).to eq(['Subfield code y'])
      end
    end
  end
end
