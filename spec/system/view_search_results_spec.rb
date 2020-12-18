# frozen_string_literal: true
require 'rails_helper'

RSpec.feature "View Search Results", type: :system, js: false do
  before do
    delete_all_documents_from_solr
    solr = Blacklight.default_index.connection
    solr.add(TEST_ITEM)
    solr.commit
    visit root_path
    click_on 'Search'
  end

  context 'displaying metadata' do
    it 'has a title link' do
      expect(page).to have_link('The Title of my Work')
    end

    it 'has the right metadata labels' do
      ['Author/Creator:', 'Resource Type:', 'Access:'].each { |label| expect(page).to have_content(label) }
    end

    it 'has the right values' do
      ['George Jenkins', 'Book', 'Electronic Resource'].each { |label| expect(page).to have_content(label) }
    end
  end
end
