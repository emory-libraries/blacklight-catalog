# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UrlFulltextPresenter do
  let(:pres) { described_class.new(document: SolrDocument.new(TEST_ITEM)) }

  context 'with a solr document' do
    describe '#url_fulltext' do
      it 'has correct return value' do
        expect(pres.url_fulltext).to eq(["{\"url\":\"http://www.example2.com\",\"label\":\"Link Text for Book\"}"])
      end
    end
  end
end
