# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Search the catalog', type: :system, js: false do
  let(:fields) do
    [
      'isbn_t', 'issn_sim', 'lccn_sim', 'oclc_sim', 'other_standard_ids_sim',
      'publisher_number_sim', 'nonformat_table_contents_tsim', 'summary_tsim',
      'participant_performer_note_tsim', 'creation_production_credits_tsim', 'local_note_tsim',
      'author_t', 'author_display', 'author_vern_display', 'author_sort', 'author_addl_t', 'subject_t',
      'title_t', 'title_vern_display', 'title_sort',
      'title_addl_t', 'title_abbr_t', 'title_added_entry_t', 'title_enhanced_t',
      'title_former_t', 'title_graphic_t', 'title_host_item_t', 'title_key_t',
      'title_preceding_entry_t', 'title_series_t', 'title_translation_t', 'title_varying_t'
    ]
  end

  before do
    delete_all_documents_from_solr
    solr = Blacklight.default_index.connection
    fields.each_with_index do |f, i|
      solr.add(
        id: "Junk#{i}",
        title_display: "Target in #{f}",
        f.to_sym => ['iMCnR6E8']
      )
    end

    solr.add(
      id: 'iMCnR6E8',
      title_display: ['Target in id']
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
      'Target in isbn_t',
      'Target in issn_sim',
      'Target in lccn_sim',
      'Target in oclc_sim',
      'Target in other_standard_ids_sim',
      'Target in publisher_number_sim',
      'Target in nonformat_table_contents_tsim',
      'Target in summary_tsim',
      'Target in participant_performer_note_tsim',
      'Target in creation_production_credits_tsim',
      'Target in local_note_tsim',
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
        'Target in author_t',
        'Target in author_display',
        'Target in author_vern_display',
        'Target in author_sort',
        'Target in author_addl_t'
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
      'Target in title_t',
      'Target in title_vern_display',
      'Target in title_sort',
      'Target in title_addl_t',
      'Target in title_abbr_t',
      'Target in title_added_entry_t',
      'Target in title_enhanced_t',
      'Target in title_former_t',
      'Target in title_graphic_t',
      'Target in title_host_item_t',
      'Target in title_key_t',
      'Target in title_preceding_entry_t',
      'Target in title_series_t',
      'Target in title_translation_t',
      'Target in title_varying_t'
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

    expect(result_titles).to contain_exactly('Target in subject_t')
  end
end
