# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Facet the catalog by year', type: :system, js: false do
  before do
    delete_all_documents_from_solr
    build_solr_docs([llama, newt, eagle])
    # The following allows the availability function to process while not delivering any
    # matching data.
    ['222,111,333', '111', '333'].each do |str|
      stub_request(:get, "https://api-na.hosted.exlibrisgroup.com/almaws/v1/bibs?apikey=some_fake_key&expand=p_avail,e_avail,d_avail&mms_id=#{str}&view=full")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_availability_test_file.xml'), headers: {})
    end
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

  # context 'from homepage' do
  #   before do
  #     visit root_path
  #     # Apply date facet with default parameters and make sure search results appear
  #     find('input[value="Apply"]').click
  #   end

  #   include_examples "gets_all_possible_documents"
  # end

  describe 'when "unknown" limiter is clicked' do
    # context 'on homepage' do
    #   before do
    #     visit root_path
    #     click_on "Unknown"
    #   end

    #   include_examples "provides_constraint_on_next_page_unknown"
    # end

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
