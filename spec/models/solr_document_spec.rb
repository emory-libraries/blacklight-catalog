# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SolrDocument do
  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_BIB_KEY']
    orig_openurl = ENV['ALMA_BASE_SANDBOX_URL']
    ENV['ALMA_API_URL'] = 'http://www.example.com'
    ENV['ALMA_BASE_SANDBOX_URL'] = 'http://www.example.com/hello'
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_BIB_KEY'] = orig_key
    ENV['ALMA_BASE_SANDBOX_URL'] = orig_openurl
  end

  before do
    delete_all_documents_from_solr
    solr = Blacklight.default_index.connection
    solr.add([TEST_ITEM, MULTIPLE_HOLDINGS_TEST_ITEM, MLA_HANDBOOK, ONLINE, FUNKY_URL_PARTY, LIMITED_AVA_INFO])
    solr.commit
  end

  context "with an alias for an identifier" do
    let(:solr_doc) { described_class.find(TEST_ITEM[:id]) }
    it "has an alias for identifier and mms_id" do
      expect(solr_doc.id).to eq(TEST_ITEM[:id])
      expect(solr_doc.mms_id).to eq(TEST_ITEM[:id])
    end
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
      expect(solr_doc.physical_holdings.last[:library][:label]).to eq "Marian K. Heilbrun Music Media"
      expect(solr_doc.physical_holdings.last[:location][:label]).to eq "Circulation Desk"
      expect(solr_doc.physical_holdings.last[:call_number]).to eq "ML410 .M5 H87 2019 CD-SOUND"
      expect(solr_doc.physical_holdings.last[:availability]).to eq({ copies: 1, available: 1, requests: 0, availability_phrase: "available" })
    end
  end

  context 'lots of holdings' do
    let(:solr_doc) { described_class.find(MLA_HANDBOOK[:id]) }

    it "can calculate complex availability information" do
      expect(solr_doc.physical_holdings[0][:availability]).to eq({ copies: 3, available: 3, requests: 0, availability_phrase: "available" })
      expect(solr_doc.physical_holdings[1][:availability]).to eq({ copies: 2, available: 2, requests: 1, availability_phrase: "available" })
      expect(solr_doc.physical_holdings[2][:availability]).to eq({ copies: 3, available: 1, requests: 0, availability_phrase: "available" })
      expect(solr_doc.online_holdings).to be nil
    end

    it "can say whether or not the title is available for a hold request" do
      expect(solr_doc.hold_requestable?).to eq true
    end
  end

  context 'physical holdings with limited information from alma' do
    let(:solr_doc) { described_class.find(LIMITED_AVA_INFO[:id]) }
    it "does not raise an error" do
      expect(solr_doc.physical_holdings[0][:availability]).to eq({ copies: 7, available: 7, requests: 0, availability_phrase: "available" })
      expect(solr_doc.physical_holdings[1][:availability]).to eq({ copies: 3, available: 3, requests: 0, availability_phrase: "available" })
      expect(solr_doc.physical_holdings[2][:availability]).to eq({ copies: nil, available: nil, requests: 0, availability_phrase: "check_holdings" })
    end
  end

  context 'online holding' do
    let(:old_style_solr_doc) { described_class.find(ONLINE[:id]) }
    let(:new_style_solr_doc) { described_class.find(ONLINE_NEW[:id]) }
    let(:online_holdings) do
      [{
        url: "http://proxy.library.emory.edu/login?url=https://doi.org/10.31022/R082-83",
        label: "Online resource from A-R Editions"
      }, {
        label: "Online resource from A-R Editions",
        url: "http://www.example.com/hello/discovery/openurl?institution=&vid=:blacklight&u.ignore_date_coverage=true&force_direct=true&portfolio_pid=53450970510002486"
      }]
    end

    it "can display online availabiliity" do
      expect(old_style_solr_doc.physical_holdings).to be nil
      expect(old_style_solr_doc.online_holdings).to eq(online_holdings)
      expect(new_style_solr_doc.online_holdings).to eq(online_holdings)
    end

    it "can say whether or not the title is available for a hold request" do
      expect(new_style_solr_doc.hold_requestable?).to eq false
    end
  end

  context 'funky url' do
    let(:solr_doc) { described_class.find(FUNKY_URL_PARTY[:id]) }
    let(:online_holdings) do
      [{
        url: "http://proxy.library.emory.edu/login?url=https://www.sciencedirect.com/science/book/9780702078798",
        label: "Online resource from Elsevier"
      }, {
        label: "Online resource from Elsevier",
        url: "http://www.example.com/hello/discovery/openurl?institution=&vid=:blacklight&u.ignore_date_coverage=true&force_direct=true&portfolio_pid=53445539330002486"
      }]
    end

    it "can display availability with the correct style" do
      expect(solr_doc.online_holdings).to eq(online_holdings)
    end
  end

  context 'work order request with no holding id' do
    let(:solr_doc) { described_class.new("990010439240302486") }

    it "can still show the requests" do
      stub_request(:get, "http://www.example.com/almaws/v1/bibs/990010439240302486/requests?status=active&apikey=fakebibkey123")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_requests/work_order_request.xml'), headers: {})
      stub_request(:get, "http://www.example.com/almaws/v1/bibs/990010439240302486?apikey=fakebibkey123&expand=p_avail,e_avail,d_avail,requests&view=full")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_availability_test_file_11.xml'), headers: {})

      expect(solr_doc.requests?).to eq true
      expect(solr_doc.retrieve_requests("22191369710002486")).to eq 0
    end
  end
end
