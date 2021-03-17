# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DescriptionSummaryPresenter do
  let(:pres) { described_class.new(document: TEST_ITEM) }
  let(:main_terms) do
    { language_tesim: ['English'],
      material_type_display_tesim: ['1 online resource (111 pages)'],
      note_general_tsim: ['General note'],
      url_suppl_ssim: ['http://www.example.com'] }
  end
  context 'with a solr document' do
    describe '#terms' do
      it 'has the correct terms' do
        expect(pres.terms).to eq(main_terms)
      end
    end
  end
end
