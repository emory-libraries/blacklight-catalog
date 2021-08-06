# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Search the catalog', type: :system, js: false do
  let(:fields) do
    [
      'author_tesim', 'author_vern_tesim', 'author_ssort', 'author_addl_display_tesim',
      'title_tesim', 'title_vern_display_tesim', 'title_addl_tesim', 'title_abbr_tesim',
      'title_added_entry_tesim', 'title_enhanced_tesim', 'subject_tesim', 'title_former_tesim',
      'title_host_item_tesim', 'title_key_tesim', 'title_series_tesim', 'title_translation_tesim',
      'title_varying_tesim', 'text_tesi', 'local_call_number_tesim', 'title_later_tesim',
      'note_production_tesim', 'note_participant_tesim'
    ]
  end

  before do
    delete_all_documents_from_solr
    solr = Blacklight.default_index.connection
    fields.each_with_index do |f, i|
      solr.add(
        id: "Junk#{i}",
        title_main_display_ssim: "Target in #{f}",
        f.to_sym => ['iMCnR6E8']
      )
    end

    solr.add(
      id: 'iMCnR6E8',
      title_main_display_ssim: ['Target in id']
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

    within '#documents' do
      result_titles += page.all(:css, 'h3.document-title-heading/a').to_a.map(&:text)
    end

    expect(result_titles).to contain_exactly(
      'Target in text_tesi',
      'Target in id',
      'Target in local_call_number_tesim'
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
        'Target in author_vern_tesim',
        'Target in author_ssort',
        'Target in author_addl_display_tesim',
        'Target in note_production_tesim',
        'Target in note_participant_tesim'
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
      'Target in title_addl_tesim',
      'Target in title_abbr_tesim',
      'Target in title_added_entry_tesim',
      'Target in title_enhanced_tesim',
      'Target in title_former_tesim',
      'Target in title_host_item_tesim',
      'Target in title_key_tesim',
      'Target in title_series_tesim',
      'Target in title_translation_tesim',
      'Target in title_varying_tesim',
      'Target in title_later_tesim'
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

    expect(result_titles).to contain_exactly('Target in subject_tesim')
  end
end
