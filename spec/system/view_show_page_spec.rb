# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "View a item's show page", type: :system, js: true, alma: true do
  around do |example|
    orig_user_key = ENV['ALMA_USER_KEY']
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_BIB_KEY']
    orig_sand_url = ENV["ALMA_BASE_URL"]
    orig_inst = ENV["INSTITUTION"]
    ENV['ALMA_USER_KEY'] = "fakeuserkey456"
    ENV["ALMA_BASE_URL"] = "http://example2.com"
    ENV['ALMA_API_URL'] = 'http://www.example.com'
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    ENV["INSTITUTION"] = "SOME_INSTITUTION"
    example.run
    ENV["ALMA_BASE_URL"] = orig_sand_url
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_BIB_KEY'] = orig_key
    ENV["INSTITUTION"] = orig_inst
    ENV['ALMA_USER_KEY'] = orig_user_key
  end
  let(:id) { '123' }

  context "with the standard test item" do
    before do
      delete_all_documents_from_solr
      build_solr_docs(TEST_ITEM)
      visit solr_document_path(id)
    end
    context 'displaying metadata' do
      let(:expected_labels) do
        [
          'Author/Creator:', 'Publication/Creation:', 'Format:', 'Edition:', 'Is Part Of:',
          'Full Title:', 'Series Titles:', 'Related/Included Titles:',
          'Variant Titles:', 'Abbreviated Titles:', 'Translated Titles:', 'Additional Author/Creators:',
          'Genre:', 'Subjects:', 'Language:', 'Physical Type/Description:', 'General Note:',
          'Related Resources Link:', 'Catalog ID (MMSID):', 'ISBN:', 'ISSN:', 'OCLC Number:',
          'Other Identifiers:', 'Publisher Number:', 'Uniform Title:', 'Former Titles:', 'Later Titles:',
          'Collection:', 'Summary:', 'Finding Aid:', 'Table of Contents:', 'Publication Note:',
          'Publication Dates:', 'Holdings Note:', 'Language Note:', 'Accessibility Note:',
          'Technical Note:', 'Restrictions on Access:', 'Use and Reproduction:',
          'Local Note:', 'Participant/Performer Note:', 'Creation/Production Credits Note:',
          'Date/Time and Place of an Event:', 'Additional Physical Form:', 'Organization and Arrangement:',
          'Biographical/Historical Note:', 'Reproduction Note:', 'Location of Originals:',
          'Ownership and Custodial History:', 'Binding Note:', 'Copy and Version Identification:',
          'Citation/Reference Note:', 'Related Collections:', 'Barcode:'
        ]
      end
      let(:expected_values) do
        [
          "George JenkinsG. Jenkins", 'A dummy publication', 'A sample edition',
          'Some Bound With Text.', 'Book',
          'More title info', 'The Jenkins Series', 'The Jenkins Story', 'Variant title',
          'Jenk. Story', 'Le Stori de Jenkins', 'Tim Jenkins', 'Genre example', 'Adventure--More Adventures.',
          'English', 'Short summary', '1 online resource (111 pages)', 'General note',
          'http://www.example.com', '123', '8675309', 'H. 4260 H.', 'M080142677',
          'SOME MAGICAL NUM .66G', 'SOME OTHER MAGICAL NUMBER .12Q', 'Uniform Title',
          'Former Titles', 'Later Titles', "Emory's Collection", "1,2: Freddy's Coming For You",
          'Finding Aid Text', 'This is a Publication Note.', 'Began with: Vol. 1, no. 1 (Jan./Feb. 2009)',
          'Hey, look! Holding notes, bustah!', 'Language notes.', 'A note on accessibility',
          'CDROM included.', 'Open Access', 'This eBook is made available Open Access under a CC BY-NC-ND 4.0 license:',
          'A local note.', 'A note about a performer.', 'Directed by Tim Burton.',
          'Filmed in Georgia, baby!', 'Also available in print.', 'Concerto in B minor.',
          'A historical note.', 'A note about this reproduction.', 'A note left by the janitor.',
          'University of Tuscaloosie', 'Notes on binding.', 'Notes on versions.', 'Notes on related collections.',
          'Some notes on citations.', '010003511601'
        ]
      end

      around do |example|
        Capybara.ignore_hidden_elements = false
        example.run
        Capybara.ignore_hidden_elements = true
      end

      it 'has the right metadata labels' do
        exposed_labels = find_all('dl.row.dl-invert.document-metadata dt').map(&:text)
        collapsed_labels = find_all('dl.row.dl-invert.collapsible-document-metadata dt').map(&:text)

        expect(exposed_labels + collapsed_labels).to match_array(expected_labels)
      end

      it 'has the right values' do
        exposed_values = find_all('dl.row.dl-invert.document-metadata dd').map(&:text)
        collapsed_values = find_all('dl.row.dl-invert.collapsible-document-metadata dd').map(&:text)

        expect(exposed_values + collapsed_values).to match_array(expected_values)
      end

      xit 'has fulltext hyperlink with text' do
        # test presence of fulltext hyperlink with link text
        expect(page).to have_link('Link Text for Book', href: 'http://www.example2.com')
      end
    end

    context 'displaying author values' do
      it 'shows a facet link for the author_display_ssim field' do
        expect(page).to have_link(
          'George Jenkins', href: '/?f%5Bauthor_display_ssim%5D%5B%5D=George+Jenkins'
        )
      end

      it 'shows a facet link for the author_vern_ssim field, when present' do
        expect(page).to have_link(
          'G. Jenkins', href: '/?f%5Bauthor_vern_ssim%5D%5B%5D=G.+Jenkins'
        )
      end
    end

    context 'displaying vernacular title' do
      it 'has the vernacular title below the main title' do
        expect(find('h1[itemprop="name"]+h2.vernacular_title_1').text).to eq('Title of my Work')
      end
    end

    context 'displaying availability table' do
      xit 'shows the Available and Online tables' do
        expect(find_all('.where-to-find-table')).not_to be_empty
        within '.where-to-find-table' do
          [
            'At the Library', 'Status', 'Robert W. Woodruff Library', 'Book Stacks',
            'PT2613 .M45 Z92 2006', '1 item, 1 available, 0 requests', 'Online', 'Access online:', 'Link Text for Book'
          ].each { |t| expect(page).to have_content(t) }
        end
      end

      # availability pulled from alma_availability_test_file_3.xml
      xit 'shows as Unavailable in the table' do
        delete_all_documents_from_solr
        build_solr_docs(TEST_ITEM.merge(id: '456'))
        visit solr_document_path('456')
        expect(find_all('.where-to-find-table table.table')).not_to be_empty

        within '.where-to-find-table' do
          [
            'At the Library', 'Status', 'Robert W. Woodruff Library', 'Book Stacks',
            'PT2613 .M45 Z92 2006', '1 item, 0 available, 0 requests', 'Online', 'Access online:',
            'Link Text for Book'
          ].each { |t| expect(page).to have_content(t) }
        end
      end

      xit 'shows online table only' do
        delete_all_documents_from_solr
        build_solr_docs(TEST_ITEM.merge(id: '789'))
        visit solr_document_path('789')

        expect(find_all('.where-to-find-table table.table')).not_to be_empty
        within '.where-to-find-table table.table' do
          ['Online', 'Access online:', 'Link Text for Book'].each { |t| expect(page).to have_content(t) }
        end
      end
    end

    context 'Tools Menu Sidebar' do
      let(:expected_tools_links_text) do
        ["Bookmark Item", "Cite", "Export as RIS", "Print", "Direct Link", "Staff View",
         "Search Tips", "Ask a Librarian", "Report a Problem", "Report Harmful Language",
         "Find more information about Books"]
      end

      it 'shows the correct links' do
        delete_all_documents_from_solr
        build_solr_docs(
          TEST_ITEM.merge(
            marc_display_tesi: File.read(
              fixture_path + '/alma_single_marc_display_tesi.xml'
            )
          )
        )
        visit solr_document_path(id)

        expect(
          find_all('.card.show-tools ul.list-group.list-group-flush li.list-group-item').map(&:text)
        ).to include(*expected_tools_links_text)
      end

      context 'citations' do
        let(:item) { TEST_ITEM.merge(id: '9937264718402486', marc_display_tesi: File.read(fixture_path + '/alma_single_marc_display_tesi.xml')) }
        let(:expected_warning_text) do
          'These citations are automatically generated and may not always be correct. ' \
            'Remember to check your citations for accuracy before including them in your work.'
        end

        before do
          delete_all_documents_from_solr
          build_solr_docs(item)
        end

        it 'has the right text' do
          visit solr_document_path(item[:id])
          click_on 'Cite'

          within '#blacklight-modal' do
            expect(page).to have_css('h5', text: 'Cite')
          end

          within 'div.modal-body .citation-warning' do
            expect(page).to have_content(expected_warning_text)
          end
        end
      end

      context 'direct-link' do
        around do |example|
          bl_url = ENV['BLACKLIGHT_BASE_URL']
          ENV['BLACKLIGHT_BASE_URL'] = 'www.example.com'
          example.run
          ENV['BLACKLIGHT_BASE_URL'] = bl_url
        end
        it 'has the correct direct link' do
          click_on 'Direct Link'
          within '#modal-window' do
            expect(page).to have_css('h5', text: 'Direct Link')
            expect(page).to have_selector('input[value="www.example.com/catalog/123"]')
          end
        end
      end

      context 'Report a Problem' do
        it 'links to the right LibWizard form' do
          element = find('li.list-group-item.report_problem a.nav-link')
          expect(element.text).to eq('Report a Problem')
          expect(element['href']).to include(
            'https://emory.libwizard.com/f/blacklight?refer_url=http', '/catalog/123'
          )
        end
      end
    end

    context 'displaying Additional Authors/Creators' do
      it 'shows a facet search hyperlink for the exact author string' do
        expect(page).to have_link("Tim Jenkins", href: "/?f%5Bauthor_addl_ssim%5D%5B%5D=Tim+Jenkins")
      end

      describe 'with a relator substring' do
        it 'shows a link followed by the relator as plain text' do
          delete_all_documents_from_solr
          build_solr_docs(
            TEST_ITEM.merge(
              author_addl_display_tesim: ["Tim Jenkins relator: editor."]
            )
          )
          visit solr_document_path(id)

          expect(find('dd.blacklight-author_addl_display_tesim').text).to eq("Tim Jenkins, editor.")
          expect(find('dd.blacklight-author_addl_display_tesim a').text).to eq("Tim Jenkins")
        end
      end

      describe 'with more than 5 items' do
        around do |example|
          Capybara.ignore_hidden_elements = false
          example.run
          Capybara.ignore_hidden_elements = true
        end

        it 'provides a collapse and div for the hidden items' do
          delete_all_documents_from_solr
          build_solr_docs(
            TEST_ITEM.merge(
              author_addl_display_tesim: ["Tina", "Lisa", "Courtney", "Tim", "Bob", "Jeff"]
            )
          )
          visit solr_document_path(id)

          expect(page).to have_link('', href: '#extended-author-addl')
          expect(page).to have_css('span', id: 'extended-author-addl')
          expect(find_all('span#extended-author-addl a').size).to eq(1)
        end
      end
    end

    context 'Subjects/Genre section' do
      describe 'check for presence of subject links' do
        it 'has hyperlinked subjects' do
          expect(page).to have_link('Adventure--More Adventures.',
            href: '/?f%5Bsubject_display_ssim%5D%5B%5D=Adventure--More+Adventures.')
        end
      end

      describe 'with fields missing' do
        before do
          delete_all_documents_from_solr
        end

        context 'subject is missing' do
          before do
            build_solr_docs(
              TEST_ITEM.except(:subject_display_ssim)
            )
            visit solr_document_path(id)
          end

          it 'does not show subject label when subject display is missing' do
            expect(page).not_to have_content('Subjects:')
            expect(page).not_to have_css('dt', class: 'blacklight-subject_display_ssim')
          end
        end

        context 'genre is missing' do
          before do
            build_solr_docs(
              TEST_ITEM.except(:genre_ssim)
            )
            visit solr_document_path(id)
          end

          it 'does not show genre label when genre display is missing' do
            expect(page).not_to have_content('Genre:')
            expect(page).not_to have_css('dt', class: 'blacklight-genre_ssim')
          end
        end

        context 'subjects and genre both missing' do
          before do
            build_solr_docs(
              TEST_ITEM.except(:genre_ssim, :subject_display_ssim)
            )
            visit solr_document_path(id)
          end

          it 'does not show genre/subject or main heading label when genre and subject display are missing' do
            expect(page).not_to have_css('h4', class: 'blacklight-Subjects/Genre')
          end
        end
      end
    end

    context 'More Search Options card' do
      it 'shows the section when format_ssim populated' do
        visit solr_document_path(id)

        expect(page.body).to have_css('h2', text: 'More Search Options')
        expect(page).to have_link('Find more information about Books')
      end

      context 'format_ssim is missing' do
        before do
          build_solr_docs(
            TEST_ITEM.except(:format_ssim)
          )
          visit solr_document_path(id)
        end

        it 'does not show the section' do
          expect(page.body).not_to have_css('h2', text: 'More Options')
          expect(page).not_to have_link('Find more information about Books')
        end
      end
    end

    context 'displaying availability on show page' do
      before do
        allow(Flipflop).to receive(:enable_requesting_using_api?).and_return(false)
        delete_all_documents_from_solr
        build_solr_docs(TEST_ITEM.merge(id: '990005988630302486'))
        visit solr_document_path('990005988630302486')
      end

      it 'shows the right badges and links' do
        find_all('span.phys-avail-label').first.should have_content('Available')
        find('.online-avail-label').should have_content('Online')
        expect(page).to have_link(
          'LOCATE', class: 'btn btn-md rounded-0 btn-outline-primary avail-physical-link-el'
        )
        expect(
          find('a.btn.btn-md.rounded-0.mb-2.btn-outline-primary.avail-online-link-el[data-target="#avail-modal-990005988630302486"]').present?
        ).to be_truthy
      end

      around do |example|
        Capybara.ignore_hidden_elements = false
        example.run
        Capybara.ignore_hidden_elements = true
      end

      it 'contains the span holding the table' do
        expect(page).to have_css('span#avail-990005988630302486-toggle', class: 'collapse')
      end
    end

    context 'viewing xml version of document' do
      let(:first_phys_holding_item) { "//physical_holdings//physical_holding//call_number[text()='PT2613 .M45 Z92 2006']/following-sibling::items//item" }
      let(:second_phys_holding_item) { "//physical_holdings//physical_holding//call_number[text()='973.933 B1682D']/following-sibling::items//item" }
      let(:expected_values_arr) do
        [['//title', 'The Title of my Work'], ['//author', 'George Jenkins'], ['//edition', 'A sample edition'],
         ['//is_physical_holding', 'false'], ['//is_electronic_holding', 'false'],
         ['//physical_description', '1 online resource (111 pages)'], ['//publisher', ''],
         ['//publication_date', '2015'], ['//isbn', 'SOME MAGICAL NUM .66G'], ['//issn', 'SOME OTHER MAGICAL NUMBER .12Q'],
         ['//supplemental_links//supplemental_link//link', 'http://www.example.com'],
         ['//supplemental_links//supplemental_link//label', 'http://www.example.com'],
         ["#{first_phys_holding_item}//library", 'UNIV'], ["#{first_phys_holding_item}//location", 'STACK'],
         ["#{first_phys_holding_item}//barcode", '010001233671'], ["#{first_phys_holding_item}//volume_or_issue", ''],
         ["#{first_phys_holding_item}//status", 'Item in place'], ["#{second_phys_holding_item}//library", 'OXFD'],
         ["#{second_phys_holding_item}//location", 'NEWNYT'], ["#{second_phys_holding_item}//barcode", '050000104980'],
         ["#{second_phys_holding_item}//volume_or_issue", ''], ["#{second_phys_holding_item}//status", 'Item in place']]
      end

      it 'displays correct tag/values' do
        visit "/catalog/#{id}.xml"
        xml = Nokogiri::XML(page.body)

        expected_values_arr.each do |arr|
          expect(xml.xpath(arr[0]).text).to eq(arr[1])
        end
      end
    end
  end

  context 'A special collections item' do
    let(:user) { User.create(uid: "janeq") }
    # rubocop:disable Layout/LineLength
    let(:openurl) { "https://aeon.library.emory.edu/aeon/aeon.dll?Action=10&Form=30&ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&rfr_id=info%3Asid%2Fprimo%3A010001072974&rft.genre=book&rft.btitle=Sitting+frog+%3A+poetry+from+Naropa+Institute&rft.title=Sitting+frog+%3A+poetry+from+Naropa+Institute&rft.au=Peters%2C+Rachel&rft.date=1976&rft.place=Brunswick%2C+Me.&rft.pub=%5BBlackberry%5D&rft.edition&rft.isbn&rft.callnumber=PS615+.S488+1976+DANOWSKI&rft.item_location=MARBL+STACK&rft.barcode=010001072974&rft.doctype=RB&rft.lib=EMU&SITE=MARBLEU" }
    # rubocop:enable Layout/LineLength
    before do
      sign_in(user)
      stub_request(:get, "http://www.example.com/almaws/v1/users/janeq?apikey=fakeuserkey456&expand=none&user_id_type=all_unique&view=full")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_users/full_user_record.xml'), headers: {})
      stub_request(:get, "http://www.example.com/almaws/v1/bibs/990005412600302486?apikey=fakebibkey123&expand=p_avail,e_avail,d_avail,requests&view=full")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_bib_records/sitting_frog.xml'), headers: {})
      stub_request(:get, "http://www.example.com/almaws/v1/bibs/990005412600302486/holdings/ALL/items?apikey=fakebibkey123&expand=due_date_policy&limit=100&offset=0&order_by=chron_i&user_id=janeq")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_item_records/990005412600302486_w_user.xml'), headers: {})
      stub_request(:get,
        "http://www.example.com/almaws/v1/bibs/990005412600302486/holdings/22177450170002486/items?apikey=fakebibkey123&expand=due_date_policy&limit=100&offset=0&order_by=chron_i&user_id=GUEST")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_item_records/990005412600302486.xml'), headers: {})
      delete_all_documents_from_solr
      build_solr_docs(SITTING_FROG)
      visit solr_document_path(SITTING_FROG[:id])
    end

    xit "has a link for special collections requests" do
      expect(page).to have_content("Sitting frog : poetry from Naropa Institute")
      within '.where-to-find-table' do
        expect(page).to have_button("Request")
        find('.dropdown-toggle').click
        expect(page).to have_link("Request from Special Collections", href: openurl)
      end
    end
  end
  context 'Holdings details' do
    before do
      delete_all_documents_from_solr
      build_solr_docs(MULTIPLE_HOLDINGS_TEST_ITEM)
      visit solr_document_path("9937004854502486")
    end

    xit "shows the location header", alma: true do
      expect(page).to have_content("Where to find it")
      expect(page).to have_content("Marian K. Heilbrun Music Media")
      expect(page).to have_content("Circulation Desk")
      expect(page).to have_content("ML410 .M5 H87 2019 CD-SOUND")
      expect(page).to have_content("1 item, 1 available, 0 requests")
    end
  end

  context "with requests" do
    let(:solr_doc) { described_class.find(MLA_HANDBOOK[:id]) }
    let(:user) { User.create(uid: "janeq") }
    before do
      delete_all_documents_from_solr
      solr = Blacklight.default_index.connection
      solr.add(MLA_HANDBOOK)
      solr.commit
      visit solr_document_path(MLA_HANDBOOK[:id])
      stub_request(:get, "http://www.example.com/almaws/v1/users/janeq?user_id_type=all_unique&view=full&expand=none&apikey=fakeuserkey456")
        .to_return(status: 200, body: File.read(fixture_path + '/alma_users/full_user_record.xml'), headers: {})
    end

    xit "shows complex holdings and requests information" do
      expect(page).to have_content('3 items, 3 available, 0 requests')
      expect(page).to have_content('3 items, 1 available, 0 requests')
      expect(page).to have_content('2 items, 2 available, 2 requests')
    end

    xit "shows item level holdings information" do
      click_link('3 items, 3 available, 0 requests')
      expect(page.body).to have_content('010002885298')
      expect(page.body).to have_content('Item in place')
      expect(page.body).to have_content('barcode')
      expect(page.body).to have_content('Non-circ., Reading Rm Only')
    end

    context 'when user signed in' do
      before do
        sign_in(user)
        visit solr_document_path(MLA_HANDBOOK[:id])
      end

      xit "has a button to request a hold" do
        within '.where-to-find-table' do
          expect(page).to have_button("Request")
          find('.dropdown-toggle').click
          expect(page).to have_link("Hold request")
          click_on("Hold request")
        end
        expect(page).to have_content('Pickup library')
      end
    end
  end

  context "online holdings" do
    let(:solr_doc) { described_class.find(ONLINE[:id]) }
    let(:user) { User.create(uid: "janeq") }
    before do
      delete_all_documents_from_solr
      solr = Blacklight.default_index.connection
      solr.add(ONLINE)
      solr.commit
      visit solr_document_path(ONLINE[:id])
    end
    xit "can find the online object" do
      expect(page).to have_content('Canzoni villanesche and villanelle')
      expect(page).to have_link("Online resource from A-R Editions", href: "http://proxy.library.emory.edu/login?url=https://doi.org/10.31022/R082-83")
      expect(page).to have_link(
        "Online resource from A-R Editions",
        href: "http://example2.com/discovery/openurl?institution=SOME_INSTITUTION&vid=SOME_INSTITUTION:blacklight&u.ignore_date_coverage=true&force_direct=true&portfolio_pid=53450970510002486"
      )
      expect(page).to have_link("Services page", href: "http://example2.com/discovery/openurl?institution=SOME_INSTITUTION&vid=SOME_INSTITUTION:blacklight&rft.mms_id=9937275387802486")
      expect(find_link("Services page")[:target]).to eq("_blank")
    end

    xit "disables the hold request link when there are no physical holdings" do
      sign_in(user)
      within '.where-to-find-table' do
        expect(page).to have_button("Request")
        find('.dropdown-toggle').click
        expect(page).not_to have_link("Hold request")
      end
    end
  end
  context "url holdings" do
    let(:solr_doc) { described_class.find(FUNKY_URL_PARTY[:id]) }
    before do
      delete_all_documents_from_solr
      solr = Blacklight.default_index.connection
      solr.add(FUNKY_URL_PARTY)
      solr.commit
      visit solr_document_path(FUNKY_URL_PARTY[:id])
    end
    xit "can find the funky url object" do
      expect(page).to have_content('Clinical cases in tropical medicine')
      expect(page).to have_link("Online resource from Elsevier", href: "http://proxy.library.emory.edu/login?url=https://www.sciencedirect.com/science/book/9780702078798")
      expect(page).to have_link(
        "Online resource from Elsevier",
        href: "http://example2.com/discovery/openurl?institution=SOME_INSTITUTION&vid=SOME_INSTITUTION:blacklight&u.ignore_date_coverage=true&force_direct=true&portfolio_pid=53445539330002486"
      )
    end
  end

  # availability pulled from alma_availability_test_file_10.xml
  context "with missing copy information" do
    let(:solr_doc) { described_class.find(LIMITED_AVA_INFO[:id]) }
    before do
      delete_all_documents_from_solr
      solr = Blacklight.default_index.connection
      solr.add(LIMITED_AVA_INFO)
      solr.commit
      visit solr_document_path(LIMITED_AVA_INFO[:id])
    end
    around do |example|
      Capybara.ignore_hidden_elements = false
      example.run
      Capybara.ignore_hidden_elements = true
    end

    xit "can display the object without copy information in the AVA field" do
      expect(page).to have_content('The Review of politics')
      within '#physical-holding-3' do
        expect(page).to have_content("Check holdings")
      end
    end

    xit "can display holding level descriptions for periodicals" do
      expect(page).to have_content('The Review of politics')
      within '#physical-holding-1' do
        expect(page).to have_content("from:69 2007 until:75 2013")
      end
    end

    context "as an unauthenticated user" do
      xit "can display item record level description" do
        click_link("7 items, 7 available, 0 requests")
        within '#physical-holding-1' do
          # mms_id - 990027507910302486
          # holding_id - 22319997630002486
          expect(page).to have_content("Bound Issue")
          expect(page).to have_content("description")
          expect(page).to have_content("v.75(2013)")
          # logged out
          expect(page).to have_content("30 Day Loan Storage")
        end
      end
    end

    # availability pulled from alma_availability_test_file_10.xml
    context "as an authenticated user" do
      before do
        stub_request(:get, "http://www.example.com/almaws/v1/users/janeq?apikey=fakeuserkey456&expand=none&user_id_type=all_unique&view=full")
          .to_return(status: 200, body: File.read(fixture_path + '/alma_users/full_user_record.xml'), headers: {})
      end
      let(:user) { User.create(uid: "janeq") }

      xit "can display item record level description" do
        sign_in(user)
        click_link("Login", match: :first)
        visit solr_document_path(LIMITED_AVA_INFO[:id])
        click_link("7 items, 7 available, 0 requests")
        within '#physical-holding-1' do
          # mms_id - 990027507910302486
          # holding_id - 22319997630002486
          expect(page).to have_content("28 Days Loan")
        end
      end
    end
  end
end
