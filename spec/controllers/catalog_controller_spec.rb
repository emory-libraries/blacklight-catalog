# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CatalogController, type: :controller do
  describe 'index fields' do
    let(:index_fields) do
      controller
        .blacklight_config
        .index_fields.keys
    end
    let(:expected_index_fields) do
      ['author_display_ssim', 'format_ssim', 'publication_main_display_ssim', 'edition_tsim']
    end
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
       'other_standard_ids_tesim', 'publisher_number_tesim', 'url_fulltext_ssm', 'title_uniform_ssim',
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
       "collection_ssim", "genre_ssim", "pub_date_isim", "lc_1letter_ssim"]
    end
    let(:homepage_facet_fields) { controller.blacklight_config.homepage_facet_fields }

    context 'homepage facet fields' do
      it { expect(homepage_facet_fields).to eq(['marc_resource_ssim', 'library_ssim', 'format_ssim', 'language_ssim', 'pub_date_isim']) }
    end

    it { expect(facet_fields).to contain_exactly(*expected_facet_fields) }
  end

  describe 'advanced search facet fields' do
    let(:adv_search_facets_config) { controller.blacklight_config.advanced_search.form_solr_parameters }
    let(:expected_facet_fields) do
      ["marc_resource_ssim", "library_ssim", "format_ssim", "language_ssim"]
    end

    context 'configuration settings' do
      it 'is set with the expected field names' do
        expect(adv_search_facets_config['facet.field']).to match_array(expected_facet_fields)
      end

      context 'facet limits' do
        let(:limiters) do
          adv_search_facets_config.select do |k, _v|
            split_key = k.split('.')
            expected_facet_fields.include?(split_key[1]) && split_key[0] == 'f'
          end
        end
        let(:limiters_values) { limiters.values }

        it 'matches the expected facet fields' do
          expect(limiters.uniq.size).to eq(expected_facet_fields.uniq.size)
        end

        it 'all set to -1 (unlimited in size)' do
          expect(limiters_values.uniq).to eq([-1])
        end
      end
    end
  end

  describe 'search fields' do
    let(:search_fields) { controller.blacklight_config.search_fields.keys }
    let(:expected_search_fields) { ['keyword', 'title', 'author', 'subject'] }
    let(:expected_advanced_search_fields) do
      ['all_fields_advanced', 'title_advanced', 'author_advanced', 'subject_advanced',
       'publisher_advanced', 'title_series_advanced', 'identifier_advanced', 'call_number_advanced']
    end

    it { expect(search_fields).to contain_exactly(*expected_search_fields + expected_advanced_search_fields) }
  end

  describe 'tool menu items' do
    let(:tool_menu_items) { controller.blacklight_config.view_config(:show).document_actions.keys }
    let(:expected_tool_menu_items) { [:bookmark, :citation, :direct_link, :export_as_ris, :feedback, :help, :librarian_view, :print] }

    it { expect(tool_menu_items).to contain_exactly(*expected_tool_menu_items) }
  end
end
