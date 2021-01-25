# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "View a item's show page", type: :system, js: true do
  before do
    delete_all_documents_from_solr
    solr = Blacklight.default_index.connection
    solr.add(TEST_ITEM)
    solr.commit
    visit solr_document_path(id)
  end

  let(:id) { '123' }

  context 'displaying metadata' do
    it 'has the right metadata labels' do
      ['Title:', 'Author/Creator:', 'Creation Date:', 'Language:', 'ISBN:',
       'Call Number:', 'MMS ID:', 'Access:'].each do |label|
        expect(page).to have_content(label)
      end
    end

    it 'has the right values' do
      ['The Title of my Work', 'George Jenkins', '2015', 'English',
       'SOME MAGICAL NUM .66G', 'ANOTHER MAGICAL NUM .78F', '123',
       'Electronic Resource'].each do |value|
        expect(page).to have_content(value)
      end
    end
  end

  context 'displaying availability badge' do
    it 'shows the Available badge' do
      expect(page).to have_css('span.badge.badge-success', text: 'Available')
    end

    it 'shows the UnAvailable badge' do
      delete_all_documents_from_solr
      solr = Blacklight.default_index.connection
      solr.add(TEST_ITEM.merge(id: '456'))
      solr.commit
      visit solr_document_path('456')

      expect(page).to have_css('span.badge.badge-danger', text: 'Unavailable')
    end

    it 'shows no badge' do
      delete_all_documents_from_solr
      solr = Blacklight.default_index.connection
      solr.add(TEST_ITEM.merge(id: '789'))
      solr.commit
      visit solr_document_path('789')

      expect(page).not_to have_css('span.badge.badge-danger', text: 'Unavailable')
      expect(page).not_to have_css('span.badge.badge-success', text: 'Available')
    end
  end
end
