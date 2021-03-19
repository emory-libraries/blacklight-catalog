# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UrlFulltextPresenter do
  let(:pres) { described_class.new(document: TEST_ITEM) }
  let(:main_terms) do
    { url_fulltext_ssm: ['http://www.example2.com'],
      url_fulltext_linktext_ssm: ['Link Text for Book'] }
  end
  context 'with a solr document' do
    describe '#terms' do
      it 'has the correct terms' do
        expect(pres.terms).to eq(main_terms)
      end
    end
  end
end
