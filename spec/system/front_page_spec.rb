# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'front page', type: :system do
  ['/', '/?_ga=2.254463560.1947920273.1649182547-1700922359.1649079393'].each do |dest|
    before do
      delete_all_documents_from_solr
      build_solr_docs(TEST_ITEM)
      visit dest
    end

    around do |example|
      orig_key = ENV['ALMA_BIB_KEY']
      ENV['ALMA_BIB_KEY'] = "some_fake_key"
      example.run
      ENV['ALMA_BIB_KEY'] = orig_key
    end

    it 'has expected text' do
      expect(page).to have_css('h3.header-search', text: 'Search books, e-books, journal and newspaper titles, videos and more')
    end

    it('does not have the Title Starts With nav') { expect(page).not_to have_css('.first-main-char-ol') }

    context 'facets' do
      let(:facet_buttons) { find_all('h3.card-header.p-0.facet-field-heading button') }
      let(:facet_headers) { facet_buttons.map(&:text) }

      it 'has the right number of facets' do
        expect(facet_buttons.size).to eq 4
      end

      it 'has the right headers' do
        expect(facet_headers).to match_array(['Resource Type', 'Language', 'Library', 'Access'])
      end
    end

    context 'header links' do
      let(:nav_links) { find_all('.non-collapse-navbar .navbar-nav .nav-link') }
      let(:link_text_arr) { nav_links.map(&:text) }
      let(:link_href_arr) { nav_links.map { |nl| nl['href'] } }
      let(:expected_results_arr) do
        [
          { text: "Home", url: "/" },
          { text: "eJournals A-Z", url: "/ejournals" },
          { text: "Articles +", url: "https://emory.primo.exlibrisgroup.com/discovery/search?vid=01GALI_EMORY:articles" },
          { text: "Databases@Emory", url: "https://guides.libraries.emory.edu/az.php" },
          { text: "My Library Card", url: "https://emory.primo.exlibrisgroup.com/discovery/account?vid=01GALI_EMORY:services&section=overview&lang=en" },
          { text: "Bookmarks 0", url: "/bookmarks" },
          { text: "History", url: "/search_history" },
          { text: "Help", url: "/help" }
        ]
      end

      it 'has all the right links' do
        nav_links.each_with_index do |_hsh, ind|
          expect(expected_results_arr[ind]).to eq({ text: link_text_arr[ind], url: link_href_arr[ind] })
        end
      end
    end
  end
end
