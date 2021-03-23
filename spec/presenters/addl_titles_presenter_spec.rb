# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AddlTitlesPresenter do
  let(:pres) { described_class.new(document: TEST_ITEM) }
  let(:details_terms) do
    { title_addl_tesim: ['More title info'], title_series_ssim: ['The Jenkins Series'],
      title_uniform_ssim: ['Uniform Title'], title_former_ssim: ['Former Titles'],
      title_later_ssim: ['Later Titles'], emory_collection_tesim: ["Emory's Collection"] }
  end
  let(:details_terms_collapsible) do
    { title_added_entry_tesim: ['The Jenkins Story'], title_varying_tesim: ['Variant title'],
      title_abbr_tesim: ['Jenk. Story'], title_translation_tesim: ['Le Stori de Jenkins'] }
  end

  context 'with a solr document' do
    describe '#terms' do
      it 'has the correct terms' do
        expect(pres.terms).to include(details_terms)
      end
    end

    describe '#terms_in_collapsible' do
      it 'has the correct terms' do
        expect(pres.terms_in_collapsible).to include(details_terms_collapsible)
      end
    end
  end
end
