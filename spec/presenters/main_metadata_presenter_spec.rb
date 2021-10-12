# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MainMetadataPresenter do
  let(:pres) { described_class.new(document: TEST_ITEM) }
  let(:main_terms) do
    { author_display_ssim: ['George Jenkins'],
      publication_main_display_ssim: ['A dummy publication'],
      format_ssim: ['Book'],
      edition_tsim: ['A sample edition'],
      local_call_number_tesim: ['MST .3000'] }
  end
  context 'with a solr document' do
    describe '#terms' do
      it 'has the correct terms' do
        expect(pres.terms).to eq(main_terms)
      end
    end
  end
end
