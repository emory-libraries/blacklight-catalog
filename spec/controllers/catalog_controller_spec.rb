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
      it { expect(field_title).to eq('title_display_tesim') }
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
      ['title_display_tesim', 'author_display_ssim', 'pub_date_tesi', 'language_facet_tesim',
       'isbn_ssim', 'lc_callnum_display_ssi', 'id', 'marc_resource_ssim']
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
      ["author_display_ssim", "format_ssim", "language_facet_tesim", "marc_resource_ssim",
       "subject_era_ssim", "subject_geo_ssim", "subject_topic_facet_ssim",
       "title_series_ssim"]
    end
    let(:homepage_facet_fields) { controller.blacklight_config.homepage_facet_fields }

    context 'homepage facet fields' do
      it { expect(homepage_facet_fields).to eq(['format_ssim', 'language_facet_tesim']) }
    end

    it { expect(facet_fields).to contain_exactly(*expected_facet_fields) }
  end

  describe 'search fields' do
    let(:search_fields) { controller.blacklight_config.search_fields.keys }
    let(:expected_search_fields) { ['keyword', 'title', 'author', 'subject'] }

    it { expect(search_fields).to contain_exactly(*expected_search_fields) }
  end
end
