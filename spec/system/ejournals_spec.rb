# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'eJournals Page', type: :system, js: false do
  before do
    delete_all_documents_from_solr
    build_solr_docs(TEST_ITEM)
    visit '/ejournals'
  end

  around do |example|
    orig_key = ENV['ALMA_BIB_KEY']
    ENV['ALMA_BIB_KEY'] = "some_fake_key"
    example.run
    ENV['ALMA_BIB_KEY'] = orig_key
  end

  context 'expected elements' do
    it 'has the correct header' do
      expect(page).to have_css('h1', text: 'eJournals A-Z')
      expect(page).to have_css('h2', text: 'Browse by eJournal Title')
    end

    it 'has Search button' do
      expect(page).to have_button(value: 'Search')
    end

    it 'has visible fields' do
      expect(page).to have_field('q')
    end

    it 'has hidden fields' do
      page.has_field? "marc_resource", type: :hidden, with: "Online"
      page.has_field? "format_ssim", type: :hidden, with: "Journal, Newspaper or Serial"
      page.has_field? "search_field", type: :hidden, with: "title_precise"
    end

    it 'has links for all letters' do
      ('A'..'Z').each { |letter| expect(page).to have_link(letter, class: 'page-link') }
    end
  end

  context 'performing simple searches' do
    it 'fill in a search' do
      fill_in 'q', with: '123'
      click_button("Search")
      expect(page).not_to have_css("The Title of my Work")
      expect(page).to have_selector('.constraint', count: 3)
    end

    it 'click on Letters' do
      click_link('A')
      expect(page).not_to have_css("The Title of my Work")
      expect(page).to have_selector('.constraint', count: 3)
    end
  end
end
