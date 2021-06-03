# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "View a item's show page", type: :system, js: true, alma: true do
  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_BIB_KEY']
    ENV['ALMA_API_URL'] = 'www.example.com'
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_BIB_KEY'] = orig_key
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
          'Author/Creator:', 'Publication/Creation:', 'Type:', 'Edition:', 'Full Title:',
          'Series Titles:', 'Related/Included Titles:', 'Variant Titles:', 'Abbreviated Titles:',
          'Translated Titles:', 'Additional Author/Creators:', 'Genre:', 'Subjects:',
          'Language:', 'Physical Type/Description:', 'General Note:', 'Related Resources Link:',
          'Catalog ID (MMSID):', 'ISBN:', 'ISSN:', 'OCLC Number:', 'Other Identifiers:',
          'Publisher Number:', 'Uniform Title:', 'Former Titles:', 'Later Titles:',
          'Collection:', 'Summary:', 'Finding Aid:', 'Table of Contents:', 'Publication Note:',
          'Publication Dates:', 'Language Note:', 'Accessibility Note:', 'Technical Note:',
          'Restrictions on Access:', 'Use and Reproduction:', 'Local Note:', 'Participant/Performer Note:',
          'Creation/Production Credits Note:', 'Date/Time and Place of an Event:',
          'Additional Physical Form:', 'Organization and Arrangement:', 'Biographical/Historical Note:',
          'Reproduction Note:', 'Location of Originals:', 'Ownership and Custodial History:',
          'Binding Note:', 'Copy and Version Identification:', 'Citation/Reference Note:',
          'Related Collections:'
        ]
      end
      let(:expected_values) do
        [
          "George JenkinsG. Jenkins", 'A dummy publication', 'A sample edition', 'Book',
          'More title info', 'The Jenkins Series', 'The Jenkins Story', 'Variant title',
          'Jenk. Story', 'Le Stori de Jenkins', 'Tim Jenkins', 'Genre example', 'Adventure--More Adventures.',
          'English', 'Short summary', '1 online resource (111 pages)', 'General note',
          'http://www.example.com', '123', '8675309', 'H. 4260 H.', 'M080142677',
          'SOME MAGICAL NUM .66G', 'SOME OTHER MAGICAL NUMBER .12Q', 'Uniform Title',
          'Former Titles', 'Later Titles', "Emory's Collection", "1,2: Freddy's Coming For You",
          'Finding Aid Text', 'This is a Publication Note.', 'Began with: Vol. 1, no. 1 (Jan./Feb. 2009)',
          'Language notes.', 'A note on accessibility', 'CDROM included.', 'Open Access',
          'This eBook is made available Open Access under a CC BY-NC-ND 4.0 license:',
          'A local note.', 'A note about a performer.', 'Directed by Tim Burton.',
          'Filmed in Georgia, baby!', 'Also available in print.', 'Concerto in B minor.',
          'A historical note.', 'A note about this reproduction.', 'A note left by the janitor.',
          'University of Tuscaloosie', 'Notes on binding.', 'Notes on versions.', 'Notes on related collections.',
          'Some notes on citations.'
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

      it 'has fulltext hyperlink with text' do
        # test presence of fulltext hyperlink with link text
        expect(page).to have_link('Link Text for Book', href: 'http://www.example2.com')
      end
    end

    context 'displaying vernacular title' do
      it 'has the vernacular title below the main title' do
        expect(find('h1[itemprop="name"]+h2.vernacular_title_1').text).to eq('Title of my Work')
      end
    end

    context 'displaying availability table' do
      it 'shows the Available and Online tables' do
        expect(find_all('.where-to-find-table')).not_to be_empty
        within '.where-to-find-table' do
          [
            'At the Library', 'Call Number', 'Status', 'Robert W. Woodruff Library: Book Stacks',
            'PT2613 .M45 Z92 2006', '1 copy, 1 available, 0 requests', 'Online', 'Access online:', 'Link Text for Book'
          ].each { |t| expect(page).to have_content(t) }
        end
      end

      it 'shows as Unavailable in the table' do
        delete_all_documents_from_solr
        build_solr_docs(TEST_ITEM.merge(id: '456'))
        visit solr_document_path('456')
        expect(find_all('.where-to-find-table table.table')).not_to be_empty

        within '.where-to-find-table' do
          [
            'At the Library', 'Call Number', 'Status', 'Robert W. Woodruff Library: Book Stacks',
            'PT2613 .M45 Z92 2006', '1 copy, 0 available, 0 requests', 'Online', 'Access online:',
            'Link Text for Book'
          ].each { |t| expect(page).to have_content(t) }
        end
      end

      it 'shows online table only' do
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
        ["Bookmark Item", "Cite", "Print", "Direct Link", "Help", "Feedback", "Staff View"]
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
        let(:expected_warning_text) do
          'These citations are automatically generated and may not always be correct. ' \
            'Remember to check your citations for accuracy before including them in your work.'
        end

        it 'has the right text' do
          # For some reason, the 3 styles load locally, but not here.
          # I looked in blacklight gem's spec for a way to work around this, but
          # all they tested for was the Cite modal title as well.
          execute_script("document.querySelector('#citationLink').click()")
          within '#blacklight-modal' do
            expect(page).to have_css('h1', text: 'Cite')
          end

          within 'div.modal-body .citation-warning.row .col-11' do
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
            expect(page).to have_css('h1', text: 'Direct Link')
            expect(page).to have_selector('input[value="www.example.com/catalog/123"]')
          end
        end
      end

      context 'Feedback' do
        it 'links to the right LibWizard form' do
          element = find('li.list-group-item.feedback a.nav-link')
          expect(element.text).to eq('Feedback')
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

    context 'More Options card' do
      it 'shows the section when format_ssim populated' do
        visit solr_document_path(id)

        expect(page).to have_css('h2', text: 'MORE OPTIONS')
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
          expect(page).not_to have_css('h2', text: 'MORE OPTIONS')
          expect(page).not_to have_link('Find more information about Books')
        end
      end
    end
  end

  context 'Holdings details' do
    before do
      delete_all_documents_from_solr
      build_solr_docs(MULTIPLE_HOLDINGS_TEST_ITEM)
      visit solr_document_path("9937004854502486")
    end

    it "shows the location header", alma: true do
      expect(page).to have_content("Where to find it")
      expect(page).to have_content("REQUEST OPTIONS")
      expect(page).to have_content("Marian K. Heilbrun Music Media")
      expect(page).to have_content("Circulation Desk")
      expect(page).to have_content("ML410 .M5 H87 2019 CD-SOUND")
      expect(page).to have_content("1 copy, 1 available, 0 requests")
    end
  end

  context "with requests" do
    let(:solr_doc) { described_class.find(MLA_HANDBOOK[:id]) }

    before do
      delete_all_documents_from_solr
      solr = Blacklight.default_index.connection
      solr.add(MLA_HANDBOOK)
      solr.commit
      visit solr_document_path(MLA_HANDBOOK[:id])
    end

    it "shows complex holdings and requests information" do
      expect(page).to have_content('3 copies, 3 available, 0 requests')
      expect(page).to have_content('3 copies, 1 available, 0 requests')
      expect(page).to have_content('2 copies, 2 available, 1 request')
      expect(page).not_to have_content('2 copies, 2 available, 1 requests')
    end

    it "has a button to request holdings" do
      within '#physical-holding-1' do
        expect(page).to have_button("Request")
        click_on("Request")
      end
      expect(page).to have_content('Pickup Library:')
    end
  end

  context "online holdings" do
    let(:solr_doc) { described_class.find(ONLINE[:id]) }
    before do
      delete_all_documents_from_solr
      solr = Blacklight.default_index.connection
      solr.add(ONLINE)
      solr.commit
      visit solr_document_path(ONLINE[:id])
    end
    it "can find the online object" do
      expect(page).to have_content('Canzoni villanesche and villanelle')
      expect(page).to have_link("Online resource from A-R Editions", href: "http://proxy.library.emory.edu/login?url=https://doi.org/10.31022/R082-83")
    end
  end
  context "online and physical holdings" do
    let(:solr_doc) { described_class.find(ONLINE_AND_PHYSICAL[:id]) }
    # http://pid.emory.edu/ark:/25593/b66vt/IA
    before do
      delete_all_documents_from_solr
      solr = Blacklight.default_index.connection
      solr.add(ONLINE_AND_PHYSICAL)
      solr.commit
      visit solr_document_path(ONLINE_AND_PHYSICAL[:id])
    end

    xit "can find the online and physical object" do
      expect(page).to have_content('Ritual and degree book of the United Brothers of Friendship')
      expect(page).to have_link("Internet Archive version", href: "https://pid.emory.edu/ark:/25593/b66vt/IA")
    end
  end
end
