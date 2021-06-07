# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SolrDocument do
  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_BIB_KEY']
    ENV['ALMA_API_URL'] = 'www.example.com'
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_BIB_KEY'] = orig_key
  end

  before do
    delete_all_documents_from_solr
    solr = Blacklight.default_index.connection
    solr.add([TEST_ITEM, MULTIPLE_HOLDINGS_TEST_ITEM, MLA_HANDBOOK, ONLINE])
    solr.commit
  end

  context "with a regular test item" do
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
  context 'holdings' do
    let(:solr_doc) { described_class.find(MULTIPLE_HOLDINGS_TEST_ITEM[:id]) }

    it 'pulls holdings data from alma' do
      expect(solr_doc.physical_holdings.last[:holding_id]).to eq "22439796790002486"
      expect(solr_doc.physical_holdings.last[:library]).to eq "Marian K. Heilbrun Music Media"
      expect(solr_doc.physical_holdings.last[:location]).to eq "Circulation Desk"
      expect(solr_doc.physical_holdings.last[:call_number]).to eq "ML410 .M5 H87 2019 CD-SOUND"
      expect(solr_doc.physical_holdings.last[:availability]).to eq({ copies: 1, available: 1, requests: 0 })
    end
  end

  context 'lots of holdings' do
    let(:solr_doc) { described_class.find(MLA_HANDBOOK[:id]) }

    it "can calculate complex availability information" do
      expect(solr_doc.physical_holdings[0][:availability]).to eq({ copies: 3, available: 3, requests: 0 })
      expect(solr_doc.physical_holdings[1][:availability]).to eq({ copies: 2, available: 2, requests: 1 })
      expect(solr_doc.physical_holdings[2][:availability]).to eq({ copies: 3, available: 1, requests: 0 })
      expect(solr_doc.online_holdings).to be nil
    end
  end

  context 'online holding' do
    let(:old_style_solr_doc) { described_class.find(ONLINE[:id]) }
    let(:new_style_solr_doc) { described_class.find(ONLINE_NEW[:id]) }
    let(:online_holdings) do
      [{
        url: "http://proxy.library.emory.edu/login?url=https://doi.org/10.31022/R082-83",
        label: "Online resource from A-R Editions"
      }]
    end

    it "can display online availabiliity" do
      expect(old_style_solr_doc.physical_holdings).to be nil
      expect(old_style_solr_doc.online_holdings).to eq(online_holdings)
      expect(new_style_solr_doc.online_holdings).to eq(online_holdings)
    end
  end
end
