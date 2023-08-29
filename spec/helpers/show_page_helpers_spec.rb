# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ShowPageHelper, type: :helper do
  before do
    delete_all_documents_from_solr
    build_solr_docs(
      [
        TEST_ITEM,
        TEST_ITEM.dup.merge(
          id: '456',
          title_vern_display_tesim: ['Title of my Work', 'My Work']
        )
      ]
    )
  end

  let(:solr_doc) { SolrDocument.find(TEST_ITEM[:id]) }
  let(:solr_doc2) { SolrDocument.find('456') }

  context '#vernacular_title_populator' do
    it 'converts a single valued vernacular title into a h2 with class name' do
      expect(helper.vernacular_title_populator(solr_doc)).to eq(
        "<h2 class=\"vernacular_title_1\">Title of my Work</h2>"
      )
    end

    it 'converts a multivalued vernacular title field into a multiple h2s separated by a breakline' do
      expect(helper.vernacular_title_populator(solr_doc2)).to eq(
        "<h2 class=\"vernacular_title_1\">Title of my Work</h2><br><h2 class=\"vernacular_title_2\">My Work</h2>"
      )
    end
  end

  context '#direct_link' do
    around do |example|
      ENV['BLACKLIGHT_BASE_URL'] = 'www.example.com'
      example.run
      ENV['BLACKLIGHT_BASE_URL'] = ''
    end
    it 'returns direct_link with correct link text' do
      expect(helper.direct_link('123')).to eq("www.example.com/catalog/123")
    end
  end

  context '#colonizer' do
    it 'takes two arguments and titles/subtitles them' do
      expect(helper.colonizer('Ace Ventura', 'Pet Detective')).to eq('Ace Ventura: Pet Detective')
    end

    it 'takes the first argument and a nil second argument and returns just the first argument' do
      expect(helper.colonizer('Stanley Kubrick', nil)).to eq('Stanley Kubrick')
    end

    it 'takes a nil first argument and whatever second argument and returns nil' do
      expect(helper.colonizer(nil, 'Garbage')).to be_nil
    end
  end
end
