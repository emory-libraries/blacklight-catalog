# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Facet the catalog by year', type: :system, js: false do
  before do
    delete_all_documents_from_solr
    build_solr_docs([llama, newt, eagle])
  end

  let(:llama) do
    {
      id: '111',
      title_main_display_tesim: ['Llama Love'],
      pub_date_isim: 1920,
      title_ssort: ['Llama Love']
    }
  end

  let(:newt) do
    {
      id: '222',
      title_main_display_tesim: ['Newt Nutrition'],
      pub_date_isim: 1940,
      title_ssort: ['Newt Nutrition']
    }
  end

  let(:eagle) do
    {
      id: '333',
      title_main_display_tesim: ['Eagle Excellence'],
      title_ssort: ['Eagle Excellence']
    }
  end

  context 'sort by Title' do
    before do
      visit root_path
      click_on 'search'
    end
    it 'has correct sorting behavior for Title (A-Z)' do
      click_on('relevance')
      click_on('Title (A-Z)')
      expect(page).to have_content('1. Eagle Excellence')
      expect(page).to have_content('2. Llama Love')
      expect(page).to have_content('3. Newt Nutrition')
    end

    it 'has correct sorting behavior for Title (Z-A)' do
      click_on('relevance')
      click_on('Title (Z-A)')
      expect(page).to have_content('3. Eagle Excellence')
      expect(page).to have_content('2. Llama Love')
      expect(page).to have_content('1. Newt Nutrition')
    end
  end
end
