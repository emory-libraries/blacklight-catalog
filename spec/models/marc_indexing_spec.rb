# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Indexing fields with custom logic' do
  let(:logger) { instance_double(Logger, "logger", info: nil, debug: nil) }
  let(:solr_doc) { SolrDocument.find('9937264718402486') }
  let(:solr_doc2) { SolrDocument.find('9937264718202486') }
  let(:solr_doc3) { SolrDocument.find('9937264717902486') }
  let(:solr_doc4) { SolrDocument.find('9937264718102486') }
  let(:solr_doc5) { SolrDocument.find('9937264718402485') }
  let(:solr_doc6) { SolrDocument.find('9937264718202485') }
  let(:solr_doc7) { SolrDocument.find('9937264717902485') }
  let(:solr_doc8) { SolrDocument.find('9937264718102485') }
  let(:solr_doc9) { SolrDocument.find('990016148150302486') }
  let(:solr_doc10) { SolrDocument.find('990023916570302486') }
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

  describe "exporting RIS formatted citation" do
    it "exports to ris" do
      # expect(solr_doc.export_as_marcxml).to be
      expect(solr_doc.export_as_ris).to be
    end
  end

  describe 'marc_resource_ssim field, when url_fulltext_ssm is populated' do
    it 'is mapped with online' do
      [solr_doc, solr_doc2, solr_doc3, solr_doc4].each do |sd|
        expect(sd['marc_resource_ssim']).to include('Online')
      end
    end
  end

  describe 'marc_resource_ssim field, when 598a equals "NEW"' do
    it('is mapped with Recently Acquired') { expect(solr_doc['marc_resource_ssim']).to include('Recently Acquired') }
  end

  describe 'marc_resource_ssim field, when 598a does not exist' do
    it 'is not mapped with Recently Acquired' do
      [solr_doc2, solr_doc3, solr_doc4].each do |d|
        expect(d['marc_resource_ssim']).not_to include('Recently Acquired')
      end
    end
  end

  describe 'marc_resource_ssim field, when no 997 or 998 fields' do
    context 'and 000/6 == e, f, g, k, o, or r and 008/29 == o or s' do
      it('is mapped with Online') { expect(solr_doc5['marc_resource_ssim']).to include('Online') }
    end

    context 'and 000/6 == e, f, g, k, o, or r and 008/29 != o or s' do
      it('is mapped with At the Library') { expect(solr_doc6['marc_resource_ssim']).to eq(['At the Library']) }
    end

    context 'and 000/6 != e, f, g, k, o, or r and 008/29 == o or s' do
      it('is mapped with Online') { expect(solr_doc7['marc_resource_ssim']).to eq(['Online']) }
    end

    context 'and 000/6 != e, f, g, k, o, or r and 008/29 != o or s' do
      it('is mapped with At the Library') { expect(solr_doc8['marc_resource_ssim']).to eq(['At the Library']) }
    end
  end

  describe 'format_ssim field' do
    context 'when leader 6 and 7 positions is am' do
      it('is mapped as a Book') { expect(solr_doc3['format_ssim']).to eq(["Book"]) }
    end

    context 'when leader 6 is e' do
      it('is mapped as a Map') { expect(solr_doc2['format_ssim']).to eq(["Map"]) }
    end

    context 'when leader 6 position is k' do
      it('is mapped as a Video or Visual Material') { expect(solr_doc10['format_ssim']).to eq(["Video or Visual Material"]) }
    end

    context 'when leader 6 position is p' do
      it('is mapped as a Archival Material or Manuscripts') { expect(solr_doc9['format_ssim']).to eq(["Archival Material or Manuscripts"]) }
    end
  end

  describe 'publication_main_dispaly_ssm field' do
    it 'maps 260, 264, and 008 fields' do
      expect(solr_doc2['publication_main_display_ssim']).to eq(["[Washington, D.C.] : [Central Intelligence Agency], [2002]"])
    end
  end

  describe 'title_details_display_tesim field' do
    it 'maps 245abp' do
      expect(solr_doc2['title_details_display_tesim']).to eq(["Physical Map Test"])
    end
  end

  describe 'publisher_details_dispaly_ssm field' do
    it 'maps 260, 264, and 008 fields' do
      expect(solr_doc2['publisher_details_display_ssim']).to eq(["[Central Intelligence Agency], [Washington, D.C.] : xx#"])
    end
  end

  describe 'title_main_display_ssim field' do
    it('maps 245abnp') { expect(solr_doc2['title_main_display_ssim']).to eq(["Physical Map Test"]) }
  end

  describe 'lc_1letter_ssim field' do
    it 'maps P - Language & Literature' do
      [solr_doc3, solr_doc4].each { |s| expect(s['lc_1letter_ssim']).to eq(['P - Language & Literature']) }
    end

    it 'does not map values when 050a and 090a are empty' do
      [solr_doc, solr_doc2].each { |s| expect(s['lc_1letter_ssim']).to be_nil }
    end
  end

  describe 'library_ssim field' do
    it 'maps HOL852 without LSC' do
      expect(solr_doc['library_ssim']).to eq(['Robert W. Woodruff Library', 'Robert W. Woodruff Library'])
    end
    it 'maps HOL852 with LSC' do
      expect(solr_doc2['library_ssim']).to eq(['Library Service Center', 'Robert W. Woodruff Library'])
    end
  end

  describe 'collection_ssim field' do
    it 'maps 710 indicator1 == 2, subfield == GEU first' do
      expect(solr_doc['collection_ssim']).to eq(
        ['Raymond Danowski Poetry Library (Emory University. General Libraries)']
      )
    end

    it('maps 490a when exact 710(s) are not found') { expect(solr_doc2['collection_ssim']).to eq(['Open-file report']) }

    it('maps 490a when it is the only field available') { expect(solr_doc4['collection_ssim']).to eq(['Bonibooks']) }

    it('maps nothing when neither field available') { expect(solr_doc3['collection_ssim']).to be_nil }
  end

  describe 'subject_display_ssim field' do
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
      expect(solr_doc2['subject_display_ssim']).not_to include(excluded_elements)
    end

    it('keeps the rest') { expect(solr_doc2['subject_display_ssim']).to match_array(included_elements) }
  end

  describe 'url_fulltext_ssm field' do
    context "when url does not include a protocol" do
      it "adds the protocol at time of index" do
        expect(solr_doc9['url_fulltext_ssm']).to eq(["{\"url\":\"https://pid.emory.edu/ark:/25593/b66vt/IA\",\"label\":\"Internet Archive version\"}"])
      end
    end

    context "when the u field is present but does not contain a url" do
      it "fails gracefully" do
        expect(solr_doc10['url_fulltext_ssm']).to eq nil
      end
    end
    context "when 856 3 and z are present and ind2 is equal to 1" do
      it 'has value of 856 3 since it has higher precedence than z' do
        expect(solr_doc['url_fulltext_ssm']).to eq(["{\"url\":\"http://purl.access.gpo.gov/GPO/LPS54510\",\"label\":\"Subfield code 3\"}"])
      end
    end

    context "when 856 y, 3, and z are present and ind2 is equal to 1" do
      it 'has value of 856 y since it has higher precedence than 3 and z' do
        expect(solr_doc2['url_fulltext_ssm']).to eq(["{\"url\":\"http://purl.access.gpo.gov/GPO/LPS54510\",\"label\":\"Subfield code y\"}",
                                                     "{\"url\":\"http://hdl.loc.gov/loc.gmd/g7540.ct000822\",\"label\":null}",
                                                     "{\"url\":\"http://purl.access.gpo.gov/GPO/LPS42214\",\"label\":null}"])
      end
    end

    context "when only 856 z is present" do
      it 'has value of 856 z' do
        expect(solr_doc4['url_fulltext_ssm']).to eq(["{\"url\":\"http://purl.access.gpo.gov/GPO/LPS54510\",\"label\":\"Subfield code z\"}"])
      end
    end

    context "when 856 y and z are present" do
      it 'has value of 856 y since it has higher precedence than z' do
        expect(solr_doc3['url_fulltext_ssm'].first).to include('Subfield code y')
      end
    end
  end

  describe 'emory_collection_tesim field' do
    it 'maps 710 indicator1 == 2, subfield code == 5 with value == GEU, pulls value from tag == a' do
      expect(solr_doc['emory_collection_tesim']).to eq(
        ['Raymond Danowski Poetry Library (Emory University. General Libraries)']
      )
    end

    it('maps nil when any of those rules do not apply') { expect(solr_doc2['emory_collection_tesim']).to be_nil }
  end

  describe 'author_addl_display_tesim field' do
    let(:expected_values) do
      [
        "Bonilla, Manuel G., 1920-", "Diocesan College (Rondebosch, South Africa)",
        "Raymond Danowski Poetry Library (Emory University. General Libraries)"
      ]
    end
    let(:expected_values_2) do
      [
        "United States. Central Intelligence Agency. Design Center",
        "United States. Central Intelligence Agency relator: spycraft"
      ]
    end
    let(:expected_values_3) { ["Bierce, Ambrose, 1842-1914? Cynic's word book relator: beer holder, caterer, and sommelier"] }

    it 'maps normally whenever 700e, 710e, or 711j do not exist' do
      expect(solr_doc['author_addl_display_tesim']).to eq(expected_values)
    end

    it 'adds a "relator:" with the relator value whenever 700e, 710e, or 711j exist' do
      expect(solr_doc2['author_addl_display_tesim']).to eq(expected_values_2)
    end

    it 'properly formats the relator substring when 3 0r more relators exist' do
      expect(solr_doc3['author_addl_display_tesim']).to eq(expected_values_3)
    end
  end

  describe 'oclc_ssim field' do
    it('maps 035a field with OCLC prefix') { expect(solr_doc3['oclc_ssim']).to eq(['808373985']) }
  end

  describe 'other_standard_ids_tesim field' do
    it 'maps 024a with prefix from indicator1' do
      # saves prefix from ind1 and value from subfield `a`, or only `a` value if ind1 is blank
      expect(solr_doc3['other_standard_ids_tesim']).to eq(["Universal Product Code: 085392844524", "DOI: 10.1163/9789401210720",
                                                           "978940121072021"])
    end
  end

  describe 'url_suppl_ssim field' do
    context "when 856 indicator2 == 2 and either y, 3, or z are present" do
      it 'has value of 856u and text = 3 since it has higher precedence than z' do
        expect(solr_doc['url_suppl_ssim']).to eq(
          [
            "http://excerpts.contentreserve.com/FormatType-425/3450-1/791128-HarryPotterAndTheSorcerersStone.mp3 text: This is the right code",
            "http://catdir.loc.gov/catdir/toc/casalini15/3065159.pdf text: Table of contents only"
          ]
        )
      end

      it 'does not contain the z value since 3 is present and has priority' do
        expect(solr_doc['url_suppl_ssim'].first).not_to include("This is not the right code.")
      end
    end

    context "when 856 indicator2 == 2 is present, but y, 3, or z are not" do
      it 'has value of 856u since none of the text fields are present' do
        expect(solr_doc2['url_suppl_ssim']).to eq(
          ["http://images.contentreserve.com/ImageType-100/3450-1/{02FAA733-5F26-4039-96FA-7DE7EE74C43B}Img100.jpg"]
        )
        expect(solr_doc2['url_suppl_ssim'].first).not_to include('text: ')
      end
    end

    context "when no 856u indicator2 == 2 fields are present" do
      it('those fields are empty') { [solr_doc3, solr_doc4].each { |sd| expect(sd['url_suppl_ssim']).to be_nil } }
    end
  end

  describe 'finding_aid_url_ssim field' do
    context "when 555au indicator1 == 0 is present" do
      it 'has value of 555u and text = a' do
        expect(solr_doc['finding_aid_url_ssim']).to eq(
          ["http://images.contentreserve.com/ImageType-100/3450-1/{02FAA733-5F26-4039-96FA-7DE7EE74C43B}Img100.jpg text: Some funky image"]
        )
      end
    end

    context "when 555u indicator1 == 0 is present, but a is not" do
      it 'has value of 555u only since the text field is not present' do
        expect(solr_doc2['finding_aid_url_ssim']).to eq(
          ["http://excerpts.contentreserve.com/FormatType-425/3450-1/791128-HarryPotterAndTheSorcerersStone.mp3"]
        )
        expect(solr_doc2['finding_aid_url_ssim'].first).not_to include('text: ')
      end
    end

    context "when no 555u indicator1 == 0 fields are present" do
      it('those fields are empty') { [solr_doc3, solr_doc4].each { |sd| expect(sd['finding_aid_url_ssim']).to be_nil } }
    end
  end

  describe 'pub_date_isim field' do
    context 'when it has a proper date range' do
      # 080707i19302010gau eng d - 008 value with 1930 and 2010 as start and end years
      it('has a date range') { expect(solr_doc3['pub_date_isim']).to eq((1930..2010).to_a) }
    end

    context 'when it is journal with end year 9999' do
      it 'has end date as current year' do
        # 750727c20109999nyuqr p 0 a0eng c - 008 value with start year 2010 and end year 9999
        expect(solr_doc4['pub_date_isim']).to eq([2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022])
      end
    end

    context 'when record doesnt have 006[6] as per noted cases' do
      # 981211s1998    caubc  cc a  fs 0   eng d - 008 value with end year missing
      it('has only one date year') { expect(solr_doc['pub_date_isim']).to eq([1998]) }
    end

    context 'when the years have non-digit characters, it kicks the values to the marc21 method' do
      # 2002 comes from the marc21 publication_date
      it('is blank') { expect(solr_doc2['pub_date_isim']).to eq([2002]) }
    end

    context 'when the end year is 0000, but the start year is valid and the 008[6] is s' do
      # 2002 comes from the marc21 publication_date
      it('takes the start year') { expect(solr_doc10['pub_date_isim']).to eq([1993]) }
    end
  end

  describe 'publication_main_display_ssim field' do
    context 'when 264 and 245fg are present' do
      it 'has correct value of 264 (with longer string) as it has higher precedence than 245fg' do
        expect(solr_doc3['publication_main_display_ssim']).to eq(["New York, New York : Viking, QuestEntourageExample [2016]"])
      end
    end

    context 'when 264 is absent' do
      it 'has value of 245 if 264 is absent, and 245 has duplicate values in f and g subfields' do
        expect(solr_doc4['publication_main_display_ssim']).to eq(["2017-2018"])
      end
    end

    context 'when 245 field only one subfield' do
      it('has correct value') { expect(solr_doc['publication_main_display_ssim']).to eq(["2017"]) }
    end
  end

  describe 'local_call_number_tesim field' do
    it 'has correct value for call number' do
      expect(solr_doc['local_call_number_tesim']).to eq(["RC451.4.G39 N53 2021", "TL789.8.U5 S434 2017"])
    end
  end

  describe 'author_display_ssim field' do
    let(:pulled_values) { [solr_doc, solr_doc2, solr_doc3, solr_doc4].map { |s| s['author_display_ssim'] } }
    let(:expected_values) do
      [
        ["Geological Survey (U.S.)"], ["United States. Central Intelligence Agency. Cartography Center"],
        ["Bierce, Ambrose, 1842-1914?"], ["Bierce, Ambrose, 1842-1914?"]
      ]
    end

    it('has correct values for author') { expect(pulled_values).to eq(expected_values) }
  end

  describe 'author_vern_ssim field' do
    it('has correct value for vernacular author') { expect(solr_doc['author_vern_ssim']).to eq(['Yackety Smackety']) }
  end

  describe 'title_ssort field' do
    it 'has a string with no puctuation' do
      match_results = [solr_doc, solr_doc2, solr_doc3, solr_doc4, solr_doc5, solr_doc6,
                       solr_doc7, solr_doc8, solr_doc9, solr_doc10].map do |d|
                         d['title_ssort']&.match(/[[:punct:]]/)
                       end
      expect(match_results.compact).to be_empty
    end
  end

  describe 'author_ssort field' do
    it 'has a string with no puctuation' do
      match_results = [solr_doc, solr_doc2, solr_doc3, solr_doc4, solr_doc5, solr_doc6,
                       solr_doc7, solr_doc8, solr_doc9, solr_doc10].map do |d|
                         d['author_ssort']&.match(/[[:punct:]]/)
                       end
      expect(match_results.compact).to be_empty
    end
  end

  describe 'title_main_first_char_ssim field' do
    it('remains empty if value is just punctuation') { expect(solr_doc10['title_main_first_char_ssim']).to be_nil }
  end

  describe 'title_precise_tesim field' do
    it('remains empty if value is just punctuation') { expect(solr_doc10['title_precise_tesim']).to be_nil }
  end

  describe 'holdings_note_tesim field' do
    it('maps the 966a fields') { expect(solr_doc['holdings_note_tesim']).to eq(['Hey, look! Holding notes, bustah!']) }
    it('returns nil when no 966a fields') { expect(solr_doc2['holdings_note_tesim']).to be_nil }
  end
end
