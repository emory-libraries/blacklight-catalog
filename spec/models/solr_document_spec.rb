# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SolrDocument do
  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_BIB_KEY']
    orig_openurl = ENV['ALMA_BASE_URL']
    orig_inst = ENV["INSTITUTION"]
    ENV['ALMA_API_URL'] = 'http://www.example.com'
    ENV['ALMA_BASE_URL'] = 'http://www.example.com/hello'
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    ENV["INSTITUTION"] = "SOME_INSTITUTION"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_BIB_KEY'] = orig_key
    ENV['ALMA_BASE_URL'] = orig_openurl
    ENV["INSTITUTION"] = orig_inst
  end

  before :all do
    delete_all_documents_from_solr
    solr = Blacklight.default_index.connection
    solr.add([TEST_ITEM, MULTIPLE_HOLDINGS_TEST_ITEM, MLA_HANDBOOK, ONLINE, FUNKY_URL_PARTY, LIMITED_AVA_INFO, SITTING_FROG, HARVARD_BUSINESS_REVIEW])
    solr.commit
  end

  let(:solr_doc) { described_class.find(TEST_ITEM[:id]) }

  context "with an alias for an identifier" do
    it "has an alias for identifier and mms_id" do
      expect(solr_doc.id).to eq(TEST_ITEM[:id])
      expect(solr_doc.mms_id).to eq(TEST_ITEM[:id])
    end
  end

  context "with a regular test item" do
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

  context "special collections only" do
    before do
      stub_request(:get, "http://www.example.com/almaws/v1/bibs/990005412600302486?apikey=fakebibkey123&expand=p_avail,e_avail,d_avail,requests&view=full")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_bib_records/sitting_frog.xml'), headers: {})
      stub_request(:get, "http://www.example.com/almaws/v1/bibs/990005412600302486/holdings/ALL/items?apikey=fakebibkey123&expand=due_date_policy&limit=100&offset=0&order_by=chron_i&user_id=janeq")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_item_records/990005412600302486_w_user.xml'), headers: {})
      stub_request(:get, "http://www.example.com/almaws/v1/bibs/9936550118202486?apikey=fakebibkey123&expand=p_avail,e_avail,d_avail,requests&view=full")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_availability_test_file_6.xml'), headers: {})
    end
    # mms_id = 990005412600302486
    let(:solr_doc) { described_class.find(SITTING_FROG[:id]) }
    let(:user) { User.create(uid: "janeq") }
    # rubocop:disable Layout/LineLength
    let(:openurl) { "https://aeon.library.emory.edu/aeon/aeon.dll?Action=10&Form=30&ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&rfr_id=info%3Asid%2Fprimo%3A010001072974&rft.genre=book&rft.btitle=Sitting+frog+%3A+poetry+from+Naropa+Institute&rft.title=Sitting+frog+%3A+poetry+from+Naropa+Institute&rft.au=Peters%2C+Rachel&rft.date=1976&rft.place=Brunswick%2C+Me.&rft.pub=%5BBlackberry%5D&rft.edition&rft.isbn&rft.callnumber=PS615+.S488+1976+DANOWSKI&rft.item_location=MARBL+STACK&rft.barcode=010001072974&rft.doctype=RB&rft.lib=EMU&SITE=MARBLEU" }
    # rubocop:enable Layout/LineLength
    it 'calculates whether a special collections item is requestable' do
      expect(solr_doc.hold_requestable?(user)).to eq false
      expect(solr_doc.special_collections_requestable?(user)).to eq true
    end

    it 'builds an openurl for aeon special collections' do
      expect(solr_doc.special_collections_url(user)).to eq openurl
    end
  end

  context 'lots of holdings' do
    let(:solr_doc) { described_class.find(MLA_HANDBOOK[:id]) }
    let(:user) { User.create(uid: "janeq") }

    it "can calculate complex availability information" do
      expect(solr_doc.physical_holdings[0][:availability]).to eq({ copies: 3, available: 3, requests: 0, availability_phrase: "available" })
      expect(solr_doc.physical_holdings[1][:availability]).to eq({ copies: 2, available: 2, requests: 2, availability_phrase: "available" })
      expect(solr_doc.physical_holdings[2][:availability]).to eq({ copies: 3, available: 1, requests: 0, availability_phrase: "available" })
      expect(solr_doc.online_holdings).to be_empty
    end

    it "limits the number of calls to the Alma API for bib requests" do
      stub_bib_request = stub_request(:get, "http://www.example.com/almaws/v1/bibs/9936550118202486?apikey=fakebibkey123&expand=p_avail,e_avail,d_avail,requests&view=full")
                         .to_return(status: 200, body: File.read(fixture_path + '/alma_availability_test_file_6.xml'), headers: {})
      solr_doc.physical_holdings
      solr_doc.physical_holdings
      solr_doc.online_holdings
      expect(stub_bib_request).to have_been_made.once
    end

    it "limits the number of calls to the Alma API for item requests" do
      stub_item_request = stub_request(:get,
                            "http://www.example.com/almaws/v1/bibs/9936550118202486/holdings/ALL/items?apikey=fakebibkey123&expand=due_date_policy&limit=100&offset=0&order_by=chron_i&user_id=GUEST")
                          .to_return(status: 200, body: File.read(fixture_path + '/alma_item_records/9936550118202486.xml'), headers: {})
      solr_doc.physical_holdings
      solr_doc.physical_holdings
      solr_doc.online_holdings
      expect(stub_item_request).to have_been_made.once
    end

    it "can say whether or not the title is available for a hold request" do
      expect(solr_doc.hold_requestable?(user)).to eq true
      expect(solr_doc.special_collections_requestable?(user)).to eq false
    end

    it "includes item information as part of physical holdings" do
      expect(solr_doc.physical_holdings[0][:holding_id]).to eq "22360885950002486"
      expect(solr_doc.physical_holdings[1][:holding_id]).to eq "22332597410002486"
      expect(solr_doc.physical_holdings[2][:holding_id]).to eq "22319658770002486"
      expect(solr_doc.physical_holdings[0][:items].count).to eq 3
      expect(solr_doc.physical_holdings[1][:items].count).to eq 2
      expect(solr_doc.physical_holdings[2][:items].count).to eq 3
      expect(solr_doc.physical_holdings[0][:items][0][:barcode]).to eq("010002885296")
      expect(solr_doc.physical_holdings[1][:items][1][:barcode]).to eq("050000091186")
      expect(solr_doc.physical_holdings[2][:items][2][:barcode]).to eq("010002954783")
    end
  end

  context "over 100 physical items" do
    let(:items_page_one_stub) do
      stub_request(:get, "http://www.example.com/almaws/v1/bibs/990027509470302486/holdings/ALL/items?apikey=fakebibkey123&expand=due_date_policy&limit=100&offset=0&order_by=chron_i&user_id=GUEST")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_item_records/990027509470302486.xml'), headers: {})
    end
    let(:items_page_two_stub) do
      stub_request(:get, "http://www.example.com/almaws/v1/bibs/990027509470302486/holdings/ALL/items?apikey=fakebibkey123&expand=due_date_policy&limit=100&offset=100&order_by=chron_i&user_id=GUEST")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_item_records/990027509470302486_2.xml'), headers: {})
    end
    before do
      items_page_one_stub
      items_page_two_stub
      stub_request(:get, "http://www.example.com/almaws/v1/bibs/990027509470302486?apikey=fakebibkey123&expand=p_avail,e_avail,d_avail,requests&view=full")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_bib_records/harvard_business_review.xml'), headers: {})
    end
    let(:solr_doc) { described_class.find(HARVARD_BUSINESS_REVIEW[:id]) }

    it "retrieves the first 100 items in a single call" do
      expect(solr_doc.physical_holdings.count).to eq 4
      expect(solr_doc.physical_holdings[0][:description]).to eq "from:1 1922 until:95 2017 "
      expect(items_page_one_stub).to have_been_made.once
    end

    it "retrieves the next set of items and combines them with the first set" do
      expect(solr_doc.physical_holdings[0][:items].count).to eq 107
      expect(solr_doc.physical_holdings[1][:items].count).to eq 1
      expect(solr_doc.physical_holdings[2][:items].count).to eq 1
      expect(solr_doc.physical_holdings[3][:items].count).to eq 24
      expect(items_page_one_stub).to have_been_made.once
      expect(items_page_two_stub).to have_been_made.once
    end
  end

  context 'physical holdings with limited information from alma' do
    let(:solr_doc) { described_class.find(LIMITED_AVA_INFO[:id]) }

    it "does not raise an error" do
      expect(solr_doc.physical_holdings[0][:availability]).to eq({ copies: 7, available: 7, requests: 0, availability_phrase: "available" })
      expect(solr_doc.physical_holdings[1][:availability]).to eq({ copies: 3, available: 3, requests: 0, availability_phrase: "available" })
      expect(solr_doc.physical_holdings[2][:availability]).to eq({ copies: nil, available: nil, requests: 0, availability_phrase: "check_holdings" })
    end

    context 'getting the policy for guest and logged in users' do
      let(:user) { User.create(uid: 'janeq') }

      it "can get the due_date_policy based on the user" do
        expect(solr_doc.items_query(user)).to eq "/holdings/ALL/items?limit=100&offset=0&expand=due_date_policy&user_id=janeq&order_by=chron_i&apikey="
        expect(solr_doc.physical_holdings(user).first[:items].last).to eq(
          {
            barcode: "010002752069", type: "Bound Issue", pid: "23236301160002486",
            policy: { policy_desc: "30 Day Loan Storage", policy_id: "17", due_date_policy: "28 Days Loan" },
            description: "v.75(2013)", status: "Item in place", type_code: "ISSBD",
            temp_library: nil, temp_location: nil, temporarily_located: "false"
          }
        )
        expect(solr_doc.hold_requestable?).to eq true
      end

      it "can get the due_date_policy for a guest user" do
        expect(solr_doc.items_query).to eq "/holdings/ALL/items?limit=100&offset=0&expand=due_date_policy&user_id=GUEST&order_by=chron_i&apikey="
        expect(solr_doc.physical_holdings.first[:items].last).to eq(
          {
            barcode: "010002752069", type: "Bound Issue", pid: "23236301160002486",
            policy: { policy_desc: "30 Day Loan Storage", policy_id: "17", due_date_policy: "Loanable" },
            description: "v.75(2013)", status: "Item in place", type_code: "ISSBD",
            temp_library: nil, temp_location: nil, temporarily_located: "false"
          }
        )
        expect(solr_doc.hold_requestable?).to eq true
      end
    end
  end

  context 'online holding' do
    let(:solr_doc) { described_class.find(ONLINE[:id]) }
    let(:online_holdings) do
      [{
        url: "http://proxy.library.emory.edu/login?url=https://doi.org/10.31022/R082-83",
        label: "Online resource from A-R Editions"
      }, {
        label: "Online resource from A-R Editions",
        url: "http://www.example.com/hello/discovery/openurl?institution=SOME_INSTITUTION&vid=SOME_INSTITUTION:blacklight&u.ignore_date_coverage=true&portfolio_pid=53450970510002486"
      }]
    end

    it "can display online availabiliity" do
      expect(solr_doc.online_holdings).to eq(online_holdings)
    end

    it "can say whether or not the title is available for a hold request" do
      expect(solr_doc.hold_requestable?).to eq false
      expect(solr_doc.special_collections_requestable?).to eq false
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
        url: "http://www.example.com/hello/discovery/openurl?institution=SOME_INSTITUTION&vid=SOME_INSTITUTION:blacklight&u.ignore_date_coverage=true&portfolio_pid=53445539330002486"
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

  context '#doc_delivery_links' do
    let(:solr_doc) { described_class.new("990010439240302486") }
    let(:user) { User.create(uid: "jose_c") }
    let(:items) do
      {
        barcode: "300000465664",
        type: "Bound Issue",
        type_code: "ISSBD",
        policy: "Not loanable",
        description: "v.1:3,5 (1970); v.2:3-4 (1971); v.3:3-4 (1972); v.4:3-4 (1973); v.8:1 (1977) v.10:2 (1979)",
        status: "Item in place"
      }
    end
    let(:phys_holdings) do
      [
        { holding_id: "22353944560002486",
          library: {
            label: "Pitts Theology Library",
            value: "THEO"
          },
          location: {
            label: "Periodicals, 2nd Floor",
            value: "PER"
          },
          call_number: "ALPHA BY TITLE",
          availability: {
            copies: 1,
            available: 1,
            requests: 0,
            availability_phrase: "available"
          },
          items: [items] }
      ]
    end
    before { allow(user).to receive(:user_group).and_return("02") }

    it "returns an array of hashes when rules pass (BUS)" do
      phys_holdings.first[:library][:value] = "BUS"
      doc_delivery_falsey
      phys_holdings.first[:location][:value] = "STACK"
      doc_delivery_truth
    end

    it "returns the right boolean value when rules align with holding and user data (CHEM)" do
      phys_holdings.first[:library][:value] = "CHEM"
      doc_delivery_falsey
      phys_holdings.first[:location][:value] = "STACK"
      doc_delivery_truth
    end

    it "returns the right boolean value when rules align with holding and user data (HLTH)" do
      phys_holdings.first[:library][:value] = "HLTH"
      doc_delivery_truth
      phys_holdings.first[:location][:value] = "CIRC"
      allow(user).to receive(:user_group).and_return("24")
      doc_delivery_falsey
    end

    it "returns the right boolean value when rules align with holding and user data (LAW)" do
      allow(user).to receive(:user_group).and_return("03")
      phys_holdings.first[:library][:value] = "LAW"
      doc_delivery_falsey
      phys_holdings.first[:location][:value] = "STACK"
      doc_delivery_truth
    end

    it "returns the right boolean value when rules align with holding and user data (LSC)" do
      phys_holdings.first[:library][:value] = "LSC"
      doc_delivery_falsey
      phys_holdings.first[:location][:value] = "USTOR"
      doc_delivery_truth
    end

    it "returns the right boolean value when rules align with holding and user data (MUSME)" do
      phys_holdings.first[:library][:value] = "MUSME"
      doc_delivery_falsey
      phys_holdings.first[:location][:value] = "STACK"
      doc_delivery_truth
    end

    it "returns the right boolean value when rules align with holding and user data (OXFD)" do
      phys_holdings.first[:library][:value] = "OXFD"
      doc_delivery_truth
      phys_holdings.first[:location][:value] = "GRNOV"
      doc_delivery_falsey
    end

    it "returns the right boolean value when rules align with holding and user data (THEO)" do
      doc_delivery_truth
      phys_holdings.first[:location][:value] = "STACK"
      doc_delivery_falsey
    end

    it "returns the right boolean value when rules align with holding and user data (UNIV)" do
      phys_holdings.first[:library][:value] = "UNIV"
      doc_delivery_falsey
      phys_holdings.first[:location][:value] = "STACK"
      doc_delivery_truth
    end
  end

  def doc_delivery_truth
    expect(solr_doc.doc_delivery_links(phys_holdings, user).first[:urls].first).to include(
        '30000046566', 'https://illiad.library.emory.edu/illiad/illiad.dll?'
      )
  end

  def doc_delivery_falsey
    expect(solr_doc.doc_delivery_links(phys_holdings, user)).to be_empty
  end
end
