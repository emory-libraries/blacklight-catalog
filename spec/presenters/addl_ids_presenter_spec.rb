# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AddlIdsPresenter do
  let(:pres) { described_class.new(document: TEST_ITEM) }
  let(:details_terms) do
    { id: '123', isbn_ssim: ['SOME MAGICAL NUM .66G'], issn_ssim: ['SOME OTHER MAGICAL NUMBER .12Q'],
      oclc_ssim: ['8675309'], other_standard_ids_ssim: ['M080142677'], publisher_number_ssim: ['H. 4260 H.'] }
  end
  context 'with a solr document' do
    describe '#terms' do
      it 'has the correct terms' do
        expect(pres.terms).to include(details_terms)
      end
    end
  end
end
