# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CatalogController, type: :controller do
  describe 'index fields' do
    let(:index_fields) do
      controller
        .blacklight_config
        .index_fields.keys
    end
    let(:expected_index_fields) { ['author_display_ssim', 'format_ssim', 'marc_resource_ssim'] }
    let(:field_title) { controller.blacklight_config.index.title_field }

    context 'field titles' do
      it { expect(field_title).to eq('title_main_display_tesim') }
    end

    it { expect(index_fields).to contain_exactly(*expected_index_fields) }
  end

  describe 'show fields' do
    let(:show_fields) do
      controller
        .blacklight_config
        .show_fields.keys
    end
    let(:expected_show_fields) do
      ['author_display_ssim', 'language_ssim', 'isbn_ssim', 'id', 'title_addl_tesim',
       'title_varying_tesim', 'edition_tsim', 'material_type_display_tesim', 'note_general_tsim',
       'publication_main_display_ssim', 'format_ssim', 'title_abbr_tesim', 'title_added_entry_tesim',
       'title_series_ssim', 'title_translation_tesim', 'author_addl_display_tesim',
       'genre_ssim', 'subject_display_ssim', 'url_suppl_ssim', 'issn_ssim', 'oclc_ssim',
       'other_standard_ids_ssim', 'publisher_number_ssim', 'url_fulltext_ssm', 'title_uniform_ssim',
       'title_former_ssim', 'title_later_ssim', 'emory_collection_tesim', 'finding_aid_url_ssim',
       'table_of_contents_tesim', 'summary_tesim', 'note_publication_tesim', 'note_publication_dates_tesim',
       'note_language_tesim', 'note_accessibility_tesim', 'note_technical_tesim',
       'note_access_restriction_tesim', 'note_use_tesim', 'note_local_tesim', 'note_participant_tesim',
       'note_production_tesim', 'note_time_place_event_tesim', 'note_addl_form_tesim',
       'note_arrangement_tesim', 'note_historical_tesim', 'note_reproduction_tesim',
       'note_location_originals_tesim', 'note_custodial_tesim', 'note_copy_identification_tesim',
       'note_binding_tesim', 'note_citation_tesim', 'note_related_collections_tesim']
    end

    it { expect(show_fields).to contain_exactly(*expected_show_fields) }
  end

  describe 'facet fields' do
    let(:facet_fields) do
      controller
        .blacklight_config
        .facet_fields.keys
    end
    let(:expected_facet_fields) do
      ["author_ssim", "format_ssim", "language_ssim", "marc_resource_ssim",
       "subject_era_ssim", "subject_geo_ssim", "subject_ssim", "library_ssim",
       "collection_ssim", "genre_ssim", "pub_date_isi", "lc_1letter_ssim"]
    end
    let(:homepage_facet_fields) { controller.blacklight_config.homepage_facet_fields }

    context 'homepage facet fields' do
      it { expect(homepage_facet_fields).to eq(['marc_resource_ssim', 'library_ssim', 'format_ssim', 'language_ssim', 'pub_date_isi']) }
    end

    it { expect(facet_fields).to contain_exactly(*expected_facet_fields) }
  end

  describe 'search fields' do
    let(:search_fields) { controller.blacklight_config.search_fields.keys }
    let(:expected_search_fields) { ['keyword', 'title', 'author', 'subject'] }

    it { expect(search_fields).to contain_exactly(*expected_search_fields) }
  end
end
