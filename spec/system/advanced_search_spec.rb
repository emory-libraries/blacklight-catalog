# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Advanced Search Page', type: :system, js: false do
  before do
    delete_all_documents_from_solr
    build_solr_docs(TEST_ITEM)
    visit '/advanced'
  end

  let(:search_fields) { CatalogController.new.blacklight_config.search_fields.keys }
  let(:pulled_search_fields) { find_all('div.form-group.advanced-search-field label').map { |e| e['for'] } }
  let(:select_facet_fields) { CatalogController.new.blacklight_config.facet_fields.keys }
  let(:pulled_search_facets) { find_all('div.form-group.advanced-search-facet label').map { |e| e['for'] } }
  let(:search_button) { find('input[type=submit][value=Search]') }
  let(:document_title_heading) { 'h3.index_title.document-title-heading.col-sm-9.col-lg-10' }

  context 'expected elements' do
    it 'has the correct header' do
      expect(page).to have_css('h1', text: 'More Search Options')
    end

    it 'has the Start Over button' do
      expect(page).to have_link('Start over', href: '/advanced')
    end

    it 'has same options as the search bar' do
      expect(pulled_search_fields).to match_array(search_fields)
    end

    it 'has selects covering all facet fields minus Publication Date' do
      expect(pulled_search_facets).to include(*select_facet_fields)
    end

    it 'has the Search button' do
      expect(search_button).not_to be_nil
    end
  end

  context 'performing simple searches' do
    it 'finds the one object with a keyword search of item id' do
      fill_in 'keyword', with: '123'
      search_button.click

      expect(page).to have_css(document_title_heading)
    end

    it 'finds the one object with a author search of additional first name' do
      fill_in 'author', with: 'George'
      search_button.click

      expect(page).to have_css(document_title_heading)
    end

    it 'finds the one object with a title search of variant title' do
      fill_in 'title', with: 'Variant'
      search_button.click

      expect(page).to have_css(document_title_heading)
    end

    it 'finds the one object with a subject search of the solr value' do
      fill_in 'subject', with: 'sample'
      search_button.click

      expect(page).to have_css(document_title_heading)
    end
  end
end