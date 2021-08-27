# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'front page', type: :system do
  before do
    delete_all_documents_from_solr
    build_solr_docs(TEST_ITEM)
    visit root_path
  end

  it 'has expected text' do
    expect(page).to have_css('h1.jumbotron-heading', text: 'Welcome!')
  end

  it('does not have the Title Starts With nav') { expect(page).not_to have_css('.first-main-char-ol') }

  context 'facets' do
    let(:facet_buttons) { find_all('h3.card-header.p-0.facet-field-heading button') }
    let(:facet_headers) { facet_buttons.map(&:text) }

    it 'has the right number of facets' do
      expect(facet_buttons.size).to eq 5
    end

    it 'has the right headers' do
      expect(facet_headers).to match_array(['Resource Type', 'Language', 'Library', 'Access', 'Publication/Creation Date'])
    end
  end
end
