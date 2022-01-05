# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'View Search Results', type: :system, js: false do
  before do
    delete_all_documents_from_solr
    build_solr_docs(TEST_ITEM)
    visit root_path
    click_on 'search'
  end

  around do |example|
    orig_key = ENV['ALMA_BIB_KEY']
    ENV['ALMA_BIB_KEY'] = "some_fake_key"
    example.run
    ENV['ALMA_BIB_KEY'] = orig_key
  end

  context 'displaying metadata' do
    it 'has a title link' do
      expect(page).to have_link('The Title of my Work')
    end

    it 'displays the vernacular title if populated' do
      expect(page).to have_css('p.vern-title-search-results-1', text: 'Title of my Work')
    end

    it 'has the right metadata labels' do
      ['Author/Creator:', 'Type:', 'Publication/Creation:', 'Edition:'].each do |label|
        expect(page).to have_content(label)
      end
    end

    it 'has the right values' do
      ['George Jenkins', 'Book', 'A dummy publication', 'A sample edition'].each do |value|
        expect(page).to have_content(value)
      end
    end

    it 'no bentobox display with empty search' do
      expect(page).to have_no_content('Looking for articles?')
    end
  end

  context 'Title Starts With section' do
    it('has a label') { expect(page).to have_content('Title Starts With') }

    it 'has links for all letters' do
      ('A'..'Z').each { |letter| expect(page).to have_link(letter, class: 'page-link') }
    end

    it 'has a link that clears this facet' do
      expect(page).to have_link('All', class: "page-link")
    end

    it 'finds the title and clears facet successfully' do
      find('.first-main-char-ol li a.page-link', text: 'T').click
      results = find_all('.documents-list article')

      expect(results).not_to be_empty

      find('.first-main-char-ol li a.page-link', text: 'All').click

      expect(results).not_to be_empty
    end

    around do |example|
      Capybara.ignore_hidden_elements = false
      example.run
      Capybara.ignore_hidden_elements = true
    end

    it 'keeps previous facets when character is chosen', js: true do
      click_on('Collection')
      click_on('American county histories')
      expect(page).to have_content 'Remove constraint Collection: American county histories'
      find('.first-main-char-ol li a.page-link', text: 'T').click
      expect(page).to have_content 'Remove constraint Collection: American county histories'
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
         'Resource Type', 'Subject', 'Genre', 'LC Classification', 'Library',
         'Publication/Creation Date']
      )
    end

    context 'when author facet link clicked' do
      it 'lists the right limiter text' do
        find('.blacklight-author_display_ssim.col-md-9 a', text: 'George Jenkins').click

        expect(page).to have_css('span.filter-name', text: 'Author')
        expect(page).not_to have_css('span.filter-name', text: 'Author Display Ssim')
        expect(page).to have_css('span.filter-value[title="George Jenkins"]')
      end
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
    it 'does not show suggestions when no results are found' do
      # blank search will return our test item in the search results, therefore, no suggestions will be displayed
      expect(page).not_to have_content 'Did you mean'
      fill_in 'q', with: '1234'
      click_on 'search'
      # above search will return no results, therefore, suggestions will be displayed
      expect(page).not_to have_content 'Did you mean'
    end
  end

  context 'displaying availability badges', js: true do
    before do
      delete_all_documents_from_solr
      build_solr_docs(TEST_ITEM.merge(id: '990005988630302486'))
      visit root_path
      click_on 'search'
    end

    around do |example|
      api_url = ENV['ALMA_API_URL']
      orig_key = ENV['ALMA_BIB_KEY']
      ENV['ALMA_API_URL'] = 'http://www.example.com'
      ENV['ALMA_BIB_KEY'] = "fakebibkey123"
      Capybara.ignore_hidden_elements = false
      example.run
      Capybara.ignore_hidden_elements = true
      ENV['ALMA_API_URL'] = api_url
      ENV['ALMA_BIB_KEY'] = orig_key
    end

    it 'shows the right badges and links' do
      expect(page).to have_selector(:id, 'availability-indicator-990005988630302486')

      within('#availability-indicator-990005988630302486') do
        expect(page).to have_xpath('//span[1]', text: 'Online', class: 'btn rounded-0 mb-2 online-avail-label avail-default')
        expect(page).to have_css('span', text: 'Available')
        expect(page).to have_xpath('//span[4]/a', text: 'LOCATE', class: 'btn btn-md rounded-0 btn-outline-primary avail-physical-link-el')
        expect(
          find('a.btn.btn-md.rounded-0.mb-2.btn-outline-primary.avail-online-link-el[data-target="#avail-modal-990005988630302486"]').present?
        ).to be_truthy
      end
    end

    it 'contains the span holding the table' do
      expect(page).to have_css('span#avail-990005988630302486-toggle', class: 'collapse')
    end
  end

  context 'articles + card', js: true do
    it 'shows up when value in query' do
      fill_in 'q', with: '123'
      click_on 'search'
      expect(page).to have_content 'Search for results in Articles +'
    end
  end
end
