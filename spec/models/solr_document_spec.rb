# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SolrDocument do
  context "with a regular test item" do
    let(:solr_doc) { described_class.find(TEST_ITEM[:id]) }
    before do
      delete_all_documents_from_solr
      solr = Blacklight.default_index.connection
      solr.add(TEST_ITEM)
      solr.commit
    end

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
  context 'holdings' do
    around do |example|
      orig_url = ENV['ALMA_API_URL']
      orig_key = ENV['ALMA_BIB_KEY']
      ENV['ALMA_API_URL'] = 'www.example.com'
      ENV['ALMA_BIB_KEY'] = "fakebibkey123"
      example.run
      ENV['ALMA_API_URL'] = orig_url
      ENV['ALMA_BIB_KEY'] = orig_key
    end

    let(:solr_doc) { described_class.find(MULTIPLE_HOLDINGS_TEST_ITEM[:id]) }

    before do
      delete_all_documents_from_solr
      solr = Blacklight.default_index.connection
      solr.add(MULTIPLE_HOLDINGS_TEST_ITEM)
      solr.commit
    end
    it 'pulls holdings data from alma' do
      expect(solr_doc.holdings.last[:library]).to eq "Marian K. Heilbrun Music Media"
      expect(solr_doc.holdings.last[:location]).to eq "Circulation Desk"
      expect(solr_doc.holdings.last[:call_number]).to eq "ML410 .M5 H87 2019 CD-SOUND"
      expect(solr_doc.holdings.last[:availability]).to eq "1 copy, 1 available, 0 requests"
    end
  end
end
