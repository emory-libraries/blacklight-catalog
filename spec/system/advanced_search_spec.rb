# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Advanced Search Page', type: :system, js: false do
  before do
    delete_all_documents_from_solr
    build_solr_docs(test_hash)
    collection_auth = Qa::LocalAuthority.create(name: 'collections')
    col = test_hash[:collection_ssim]
    Qa::LocalAuthorityEntry.create(local_authority: collection_auth, label: col, uri: col)
    visit '/advanced'
  end

  around do |example|
    orig_key = ENV['ALMA_BIB_KEY']
    ENV['ALMA_BIB_KEY'] = "some_fake_key"
    example.run
    ENV['ALMA_BIB_KEY'] = orig_key
  end

  let(:test_hash) { TEST_ITEM }
  let(:search_fields) { CatalogController.new.blacklight_config.search_fields.reject { |_k, v| v.include_in_advanced_search == false }.keys }
  let(:pulled_search_fields) { find_all('div.form-group.advanced-search-field label').map { |e| e['for'] } }
  let(:select_facet_fields) { CatalogController.new.blacklight_config.advanced_search[:form_solr_parameters]["facet.field"] }
  let(:pulled_search_facets) { find_all('div.form-group.advanced-search-facet label').map { |e| e['for'] } }
  let(:search_button) { find("input[type=submit][value='Search']") }
  let(:document_title_heading) { 'h3.index_title.document-title-heading.col-sm-9.col-lg-10' }

  context 'expected elements' do
    it 'has the correct header' do
      expect(page).to have_css('h1', text: 'Search')
    end

    it 'has the Start Over button' do
      expect(page).to have_link('Clear Form', href: '/advanced')
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

    it 'has Collection facet dropdown with correct option' do
      expect(page).to have_select("collection_ssim", with_options: ['American county histories'])
    end
  end

  context 'performing simple searches' do
    it 'finds the one object with a keyword search of item id' do
      test_for_result('identifier_advanced', '123')
    end

    it 'finds the one object with a author search of additional first name' do
      test_for_result('author_advanced', 'George')
    end

    it 'finds the one object with a title search of variant title' do
      test_for_result('title_advanced', 'Variant')
    end

    it 'finds the one object with a subject search of the solr value' do
      test_for_result('subject_advanced', 'sample')
    end

    it 'finds the one object with a main title (wildcard) search of the solr value' do
      test_for_result('title_wildcard_advanced', 'T*')
    end
  end

  it 'can reach advanced search page from search results page' do
    visit '/'
    find('#search').click
    click_link 'Advanced Search'
    expect(page).to have_content 'Find items that match'
  end

  context 'issn_t search pattern' do
    let(:test_value) { '0048-671X' }
    let(:test_hash) { TEST_ITEM.merge(issn_ssim: test_value) }

    describe('when issn equals 0048-671X') do
      it('returns the result') { test_for_result('identifier_advanced', test_value) }
    end

    describe 'when issn equals 0048671X' do
      let(:test_value) { '0048671X' }

      it('returns the result') { test_for_result('identifier_advanced', test_value) }
    end
  end

  def test_for_result(input_name, test_text)
    fill_in input_name, with: test_text
    search_button.click

    expect(page).to have_css(document_title_heading)
  end
end
