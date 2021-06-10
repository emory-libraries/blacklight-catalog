# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'View Search Results', type: :system, js: false do
  before do
    delete_all_documents_from_solr
    build_solr_docs(TEST_ITEM)
    visit root_path
    click_on 'search'
  end

  context 'displaying metadata' do
    it 'has a title link' do
      expect(page).to have_link('The Title of my Work')
    end

    it 'displays the vernacular title if populated' do
      expect(page).to have_css('p.vern-title-search-results-1', text: 'Title of my Work')
    end

    it 'has the right metadata labels' do
      ['Author/Creator:', 'Type:', 'Publication/Creation:', 'Edition:'].each { |label| expect(page).to have_content(label) }
    end

    it 'has the right values' do
      ['George Jenkins', 'Book', 'A dummy publication', 'A sample edition'].each do |value|
        expect(page).to have_content(value)
      end
    end
  end

  context 'facets' do
    let(:facet_buttons) { find_all('h3.card-header.p-0.facet-field-heading button') }
    let(:facet_headers) { facet_buttons.map(&:text) }

    it 'has the right number of facets' do
      expect(facet_buttons.size).to eq 12
    end

    it 'has the right headers' do
      expect(facet_headers).to match_array(
        ['Access', 'Author/Creator', 'Collection', 'Era', 'Language', 'Region',
         'Resource Type', 'Subject', 'Genre', 'LC Classification', 'Library', 'Publication/Creation Date']
      )
    end
  end

  context 'A-Z facet navigation' do
    before do
      delete_all_documents_from_solr
      build_solr_docs(TEST_ITEM.merge(subject_era_ssim: ['1990-', 'History', 'Social Science', '19th Century', 'Example', 'Another Example']))
      visit root_path
      click_on 'search'
    end

    it 'has A-Z navigation for certain facets', js: true do
      click_on('Era')
      click_on('more')
      click_on('A-Z Sort')
      expect(page).to have_link('1')
      expect(page).to have_link('C')
    end
  end

  context 'spellcheck suggestions', js: true do
    it 'shows suggestions only when no results are found' do
      # blank search will return our test item in the search results, therefore, no suggestions will be displayed
      expect(page).not_to have_content 'Did you mean'
      fill_in 'q', with: '1234'
      click_on 'search'
      # above search will return no results, therefore, suggestions will be displayed
      expect(page).to have_content 'Did you mean'
    end
  end
end
