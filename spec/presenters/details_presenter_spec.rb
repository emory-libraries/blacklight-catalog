# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DetailsPresenter do
  let(:pres) { described_class.new(document: TEST_ITEM) }
  let(:details_terms) do
    { title_details_display_tesim: ['The Title of my Work'], title_addl_tesim: ['More title info'],
      title_varying_tesim: ['Variant title'], subject_tsim: ['A sample subject'],
      edition_tsim: ['A sample edition'], pub_date_tesi: '2015',
      material_type_display_tesim: ['1 online resource (111 pages)'], note_general_tsim: ['General note'],
      language_tesim: ['English'], summary_tesim: ['Short summary'],
      isbn_ssim: ['SOME MAGICAL NUM .66G'], publisher_details_display_ssm: ['Atlanta'],
      format_ssim: ['Book'], lc_callnum_display_ssi: 'ANOTHER MAGICAL NUM .78F',
      author_display_ssim: ['George Jenkins'], id: '123' }
  end
  context 'with a solr document' do
    describe '#terms' do
      it 'has the correct terms' do
        expect(pres.terms).to include(details_terms)
      end
    end
  end
end
