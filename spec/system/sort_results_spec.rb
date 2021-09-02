# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Facet the catalog by year', type: :system, js: false do
  before do
    delete_all_documents_from_solr
    build_solr_docs([llama, newt, eagle])
    # The following allows the availability function to process while not delivering any
    # matching data.
    ['111', '333', '333,111,222', '111,333,222', '222,333,111'].each do |str|
      stub_request(:get, "https://api-na.hosted.exlibrisgroup.com/almaws/v1/bibs?apikey=some_fake_key&expand=p_avail,e_avail,d_avail&mms_id=#{str}&view=full")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_availability_test_file.xml'), headers: {})
    end
    visit root_path
    click_on 'search'
    click_on 'Relevance'
  end

  around do |example|
    orig_key = ENV['ALMA_BIB_KEY']
    ENV['ALMA_BIB_KEY'] = "some_fake_key"
    example.run
    ENV['ALMA_BIB_KEY'] = orig_key
  end

  let(:llama) do
    {
      id: '111',
      title_main_display_ssim: ['Llama Love'],
      pub_date_isim: 1920,
      title_ssort: ['Llama Love'],
      author_ssort: 'Knots, Donald'
    }
  end

  let(:newt) do
    {
      id: '222',
      title_main_display_ssim: ['Newt Nutrition'],
      pub_date_isim: 1940,
      title_ssort: ['Newt Nutrition'],
      author_ssort: 'Tramer, Ben'
    }
  end

  let(:eagle) do
    {
      id: '333',
      title_main_display_ssim: ['Eagle Excellence'],
      title_ssort: ['Eagle Excellence'],
      author_ssort: 'Ruehl, Mercedes'
    }
  end

  context 'sort by Title' do
    it 'has correct sorting behavior for Title (A-Z)' do
      click_on('Title (A-Z)')
      expect(page).to have_content('1. Eagle Excellence')
      expect(page).to have_content('2. Llama Love')
      expect(page).to have_content('3. Newt Nutrition')
    end

    it 'has correct sorting behavior for Title (Z-A)' do
      click_on('Title (Z-A)')
      expect(page).to have_content('3. Eagle Excellence')
      expect(page).to have_content('2. Llama Love')
      expect(page).to have_content('1. Newt Nutrition')
    end
  end

  context 'sort by Year' do
    it 'has correct sorting behavior for Year (oldest)' do
      click_on('Year (oldest)')
      expect(page).to have_content('1. Eagle Excellence')
      expect(page).to have_content('2. Llama Love')
      expect(page).to have_content('3. Newt Nutrition')
    end

    it 'has correct sorting behavior for Year (newest)' do
      click_on('Year (newest)')
      expect(page).to have_content('1. Newt Nutrition')
      expect(page).to have_content('2. Llama Love')
      expect(page).to have_content('3. Eagle Excellence')
    end
  end

  context 'sort by Author' do
    let(:expected_asc_headers) { ['1. Llama Love', '2. Eagle Excellence', '3. Newt Nutrition'] }
    let(:expected_desc_headers) { ['1. Newt Nutrition', '2. Eagle Excellence', '3. Llama Love'] }

    it 'has correct sorting behavior for Author (A-Z)' do
      click_on('Author (A-Z)')
      pulled_headers = find_all('#documents.documents-list article header').map(&:text)

      expect(pulled_headers).to eq(expected_asc_headers)
    end

    it 'has correct sorting behavior for Author (Z-A)' do
      click_on('Author (Z-A)')
      pulled_headers = find_all('#documents.documents-list article header').map(&:text)

      expect(pulled_headers).to eq(expected_desc_headers)
    end
  end
end
