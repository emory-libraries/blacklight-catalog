# frozen_string_literal: true
require 'rails_helper'

RSpec.describe RelatedNamesPresenter do
  let(:pres) { described_class.new(document: TEST_ITEM) }
  let(:details_terms) { { author_addl_tesim: ['Tim Jenkins'] } }

  context 'with a solr document' do
    describe '#terms' do
      it 'has the correct terms' do
        expect(pres.terms).to include(details_terms)
      end
    end
  end
end
