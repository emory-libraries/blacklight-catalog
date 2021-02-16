# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Facet the catalog by year', type: :system, js: false do
  before do
    delete_all_documents_from_solr
    solr = Blacklight.default_index.connection
    solr.add([llama, newt, eagle])
    solr.commit
  end

  let(:llama) do
    {
      id: '111',
      title_main_display_tesim: ['Llama Love'],
      pub_date_isi: 1920
    }
  end

  let(:newt) do
    {
      id: '222',
      title_main_display_tesim: ['Newt Nutrition'],
      pub_date_isi: 1940
    }
  end

  let(:eagle) do
    {
      id: '333',
      title_main_display_tesim: ['Eagle Excellence']
    }
  end

  it 'gets correct search results using year ranges' do
    visit root_path
    click_on 'search'

    within '#documents' do
      expect(page).to have_content('Llama Love')
      expect(page).to have_content('Newt Nutrition')
      expect(page).to have_content('Eagle Excellence')
    end

    find('input#range_pub_date_isi_begin').set('1920')
    find('input#range_pub_date_isi_end').set('1925')
    find("input[value$='Apply']").click

    within '#documents' do
      expect(page).to     have_content('Llama Love')
      expect(page).not_to have_content('Newt Nutrition')
      expect(page).not_to have_content('Eagle Excellence')
    end
  end
end
