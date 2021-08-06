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
      title_main_display_ssim: ['Llama Love'],
      pub_date_isim: 1920
    }
  end

  let(:newt) do
    {
      id: '222',
      title_main_display_ssim: ['Newt Nutrition'],
      pub_date_isim: 1940
    }
  end

  let(:eagle) do
    {
      id: '333',
      title_main_display_ssim: ['Eagle Excellence']
    }
  end

  context 'from search results page' do
    before do
      visit root_path
      click_on 'search'
    end

    include_examples "gets_all_possible_documents"

    it 'returns limited results when faceted' do
      find('input#range_pub_date_isim_begin').set('1920')
      find('input#range_pub_date_isim_end').set('1925')
      find("input[value$='Apply']").click

      within '#documents' do
        expect(page).to     have_content('Llama Love')
        expect(page).not_to have_content('Newt Nutrition')
        expect(page).not_to have_content('Eagle Excellence')
      end
    end
  end

  context 'from homepage' do
    before do
      visit root_path
      # Apply date facet with default parameters and make sure search results appear
      find('input[value="Apply"]').click
    end

    include_examples "gets_all_possible_documents"
  end

  describe 'when "unknown" limiter is clicked' do
    context 'on homepage' do
      before do
        visit root_path
        click_on "Unknown"
      end

      include_examples "provides_constraint_on_next_page_unknown"
    end

    context 'on search results page' do
      before do
        visit root_path
        click_on 'search'
        click_on "Unknown"
      end

      include_examples "provides_constraint_on_next_page_unknown"
    end
  end
end
