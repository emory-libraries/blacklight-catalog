# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SolrDocument do
  before do
    delete_all_documents_from_solr
    solr = Blacklight.default_index.connection
    solr.add(TEST_ITEM)
    solr.commit
  end

  let(:solr_doc) { described_class.find(TEST_ITEM[:id]) }

  context '#combined_author_display_vern' do
    it 'combines together author_display_ssim and author_vern_ssim' do
      expect(solr_doc.combined_author_display_vern).to eq ['George Jenkins', 'G. Jenkins']
    end
  end

  context '#more_options' do
    it 'pulls the format_ssim value' do
      expect(solr_doc.more_options).to eq solr_doc['format_ssim']
    end
  end
end
