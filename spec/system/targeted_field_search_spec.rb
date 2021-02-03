# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Search the catalog', type: :system, js: false do
  let(:fields) do
    [
      'isbn_ssim', 'subtitle_display_tesim', 'subtitle_vern_display_tesim', 'subject_addl_tsim',
      'subject_topic_facet_ssim', 'subject_era_ssim', 'subject_geo_ssim', 'lc_callnum_display_ssi',
      'author_tesim', 'author_display_ssim', 'author_vern_ssim', 'author_si', 'author_addl_tesim',
      'subject_tsim', 'title_tesim', 'title_vern_display_tesim', 'title_ssort',
      'title_addl_tesim', 'title_abbr_tesim', 'title_added_entry_tesim', 'title_enhanced_tesim',
      'title_former_tesim', 'title_graphic_tesim', 'title_host_item_tesim', 'title_key_tesi',
      'title_series_ssim', 'title_translation_tesim', 'title_varying_tesim'
    ]
  end

  before do
    delete_all_documents_from_solr
    solr = Blacklight.default_index.connection
    fields.each_with_index do |f, i|
      solr.add(
        id: "Junk#{i}",
        title_display_tesim: "Target in #{f}",
        f.to_sym => ['iMCnR6E8']
      )
    end

    solr.add(
      id: 'iMCnR6E8',
      title_display_tesim: ['Target in id']
    )
    solr.commit
    visit root_path
  end

  it 'has the right options' do
    options = find_all('select.custom-select.search-field > option').map(&:text)

    expect(options).to contain_exactly('Keyword', 'Title', 'Author/Creator', 'Subjects')
  end

  it 'searches the right fields for Keyword target' do
    page.select('Keyword', from: 'search_field')
    fill_in 'q', with: 'iMCnR6E8'
    click_on 'search'
    result_titles = []

    loop do
      within '#documents' do
        result_titles += page.all(:css, 'h3.document-title-heading/a').to_a.map(&:text)
      end
      break if page.has_link?('Next', href: '#')
      click_link('Next', match: :first)
    end

    expect(result_titles).to contain_exactly(
      'Target in isbn_ssim',
      'Target in subtitle_display_tesim',
      'Target in subtitle_vern_display_tesim',
      'Target in subject_tsim',
      'Target in subject_addl_tsim',
      'Target in subject_topic_facet_ssim',
      'Target in subject_era_ssim',
      'Target in subject_geo_ssim',
      'Target in lc_callnum_display_ssi',
      'Target in author_display_ssim',
      'Target in author_vern_ssim',
      'Target in author_addl_tesim',
      'Target in title_added_entry_tesim',
      'Target in title_addl_tesim',
      'Target in title_series_ssim',
      'Target in title_vern_display_tesim',
      'Target in id'
    )
  end

  it 'searches the right fields for Author target' do
    page.select('Author', from: 'search_field')
    fill_in 'q', with: 'iMCnR6E8'
    click_on 'search'
    result_titles = []

    within '#documents' do
      result_titles += page.all(:css, 'h3.document-title-heading/a').to_a.map(&:text)
      expect(result_titles).to contain_exactly(
        'Target in author_tesim',
        'Target in author_display_ssim',
        'Target in author_vern_ssim',
        'Target in author_si',
        'Target in author_addl_tesim'
      )
    end
  end

  it 'searches the right fields for Title target' do
    page.select('Title', from: 'search_field')
    fill_in 'q', with: 'iMCnR6E8'
    click_on 'search'
    result_titles = []

    loop do
      within '#documents' do
        result_titles += page.all(:css, 'h3.document-title-heading/a').to_a.map(&:text)
      end
      break if page.has_link?('Next', href: '#')
      click_link('Next', match: :first)
    end

    expect(result_titles).to contain_exactly(
      'Target in title_tesim',
      'Target in title_vern_display_tesim',
      'Target in title_ssort',
      'Target in title_addl_tesim',
      'Target in title_abbr_tesim',
      'Target in title_added_entry_tesim',
      'Target in title_enhanced_tesim',
      'Target in title_former_tesim',
      'Target in title_graphic_tesim',
      'Target in title_host_item_tesim',
      'Target in title_key_tesi',
      'Target in title_series_ssim',
      'Target in title_translation_tesim',
      'Target in title_varying_tesim'
    )
  end

  it 'searches the right field for Subject target' do
    page.select('Subjects', from: 'search_field')
    fill_in 'q', with: 'iMCnR6E8'
    click_on 'search'
    result_titles = []

    within '#documents' do
      result_titles += page.all(:css, 'h3.document-title-heading/a').to_a.map(&:text)
    end

    expect(result_titles).to contain_exactly('Target in subject_tsim')
  end
end
