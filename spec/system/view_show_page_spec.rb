# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "View a item's show page", type: :system, js: true do
  before do
    delete_all_documents_from_solr
    build_solr_docs(TEST_ITEM)
    visit solr_document_path(id)
  end

  let(:id) { '123' }

  context 'displaying metadata' do
    let(:expected_labels) do
      [
        'Author/Creator:', 'Publication/Creation Information:', 'Type:', 'Edition:',
        'Full Title:', 'Series Titles:', 'Related/Included Titles:', 'Variant Titles:',
        'Abbreviated Titles:', 'Translated Titles:', 'Additional Author/Creators:',
        'Genre:', 'Subjects:', 'Language:', 'Physical Type/Desription:', 'General Note:',
        'Related Resources Link:', 'Catalog ID (MMSID):', 'ISBN:', 'ISSN:', 'OCLC Number:',
        'Other Identifiers:', 'Publisher Number:'
      ]
    end
    let(:expected_values) do
      [
        'George Jenkins', 'A dummy publication', 'A sample edition', 'Book', 'More title info',
        'The Jenkins Series', 'The Jenkins Story', 'Variant title', 'Jenk. Story',
        'Le Stori de Jenkins', 'Tim Jenkins', 'Genre example', 'Adventure', 'English',
        '1 online resource (111 pages)', 'General note', 'http://www.example.com',
        '123', '8675309', 'H. 4260 H.', 'M080142677', 'SOME MAGICAL NUM .66G',
        'SOME OTHER MAGICAL NUMBER .12Q'
      ]
    end

    it 'has the right metadata labels' do
      expect(find_all('dl.row.dl-invert.document-metadata dt').map(&:text)).to match_array(expected_labels)
    end

    it 'has the right values' do
      expect(find_all('dl.row.dl-invert.document-metadata dd').map(&:text)).to match_array(expected_values)
    end
  end

  context 'displaying availability badge' do
    it 'shows the Available badge' do
      expect(page).to have_css('span.badge.badge-success', text: 'Available')
    end

    it 'shows the Unavailable badge' do
      delete_all_documents_from_solr
      build_solr_docs(TEST_ITEM.merge(id: '456'))
      visit solr_document_path('456')

      expect(page).to have_css('span.badge.badge-danger', text: 'Unavailable')
    end

    it 'shows no badge' do
      delete_all_documents_from_solr
      build_solr_docs(TEST_ITEM.merge(id: '789'))
      visit solr_document_path('789')

      expect(page).not_to have_css('span.badge.badge-danger', text: 'Unavailable')
      expect(page).not_to have_css('span.badge.badge-success', text: 'Available')
    end
  end

  context 'displaying Librarian View' do
    it 'shows the link' do
      delete_all_documents_from_solr
      build_solr_docs(
        TEST_ITEM.merge(
          marc_display_tesi: File.read(
            fixture_path + '/alma_single_marc_display_tesi.xml'
          )
        )
      )
      visit solr_document_path('123')

      expect(page).to have_link('Librarian View')
    end
  end
end
