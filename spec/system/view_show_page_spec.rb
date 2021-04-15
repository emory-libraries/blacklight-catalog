# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "View a item's show page", type: :system, js: true do
  before do
    delete_all_documents_from_solr
    build_solr_docs(TEST_ITEM)
    visit solr_document_path(id)
  end

  let(:id) { '123' }

  context 'displaying metadata' do
    let(:expected_labels) do
      [
        'Author/Creator:', 'Publication/Creation:', 'Type:', 'Edition:',
        'Full Text Access:', 'Full Title:', 'Series Titles:', 'Related/Included Titles:',
        'Variant Titles:', 'Abbreviated Titles:', 'Translated Titles:', 'Additional Author/Creators:',
        'Genre:', 'Subjects:', 'Language:', 'Physical Type/Description:', 'General Note:',
        'Related Resources Link:', 'Catalog ID (MMSID):', 'ISBN:', 'ISSN:', 'OCLC Number:',
        'Other Identifiers:', 'Publisher Number:', 'Uniform Title:', 'Former Titles:',
        'Later Titles:', 'Collection:', 'Summary:', 'Finding Aid:', 'Table of Contents:',
        'Publication Note:', 'Publication Dates:', 'Language Note:', 'Accessibility Note:',
        'Technical Note:', 'Restrictions on Access:', 'Use and Reproduction:', 'Local Note:',
        'Participant/Performer Note:', 'Creation/Production Credits Note:', 'Date/Time and Place of an Event:',
        'Additional Physical Form:', 'Organization and Arrangement:', 'Biographical/Historical Note:',
        'Reproduction Note:', 'Location of Originals:', 'Ownership and Custodial History:',
        'Binding Note:', 'Copy and Version Identification:', 'Citation/Reference Note:',
        'Related Collections:'
      ]
    end
    let(:expected_values) do
      [
        "George JenkinsG. Jenkins", 'A dummy publication', 'A sample edition', 'Book', 'More title info',
        'Link Text for Book', 'The Jenkins Series', 'The Jenkins Story', 'Variant title',
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

    context 'citations' do
      it 'has the right title header' do
        # For some reason, the 3 styles load locally, but not here.
        # I looked in blacklight gem's spec for a way to work around this, but
        # all they tested for was the Cite modal title as well.
        execute_script("document.querySelector('#citationLink').click()")
        within 'div.modal-body' do
          expect(page).to have_css('h1', class: 'modal-title', text: TEST_ITEM[:title_main_display_tesim].first)
        end
      end
    end
  end

  context 'displaying vernacular title' do
    it 'has the vernacular title below the main title' do
      expect(find('h1[itemprop="name"]+h2.vernacular_title_1').text).to eq('Title of my Work')
    end
  end

  context 'displaying availability badge' do
    it 'shows the Available badge' do
      expect(page).to have_css('span.badge.badge-success', text: 'Available')
    end

    it 'shows the Unavailable badge' do
      delete_all_documents_from_solr
      build_solr_docs(TEST_ITEM.merge(id: '456'))
      visit solr_document_path('456')

      expect(page).to have_css('span.badge.badge-danger', text: 'Unavailable')
    end

    it 'shows no badge' do
      delete_all_documents_from_solr
      build_solr_docs(TEST_ITEM.merge(id: '789'))
      visit solr_document_path('789')

      expect(page).not_to have_css('span.badge.badge-danger', text: 'Unavailable')
      expect(page).not_to have_css('span.badge.badge-success', text: 'Available')
    end
  end

  context 'displaying Librarian View' do
    it 'shows the link' do
      delete_all_documents_from_solr
      build_solr_docs(
        TEST_ITEM.merge(
          marc_display_tesi: File.read(
            fixture_path + '/alma_single_marc_display_tesi.xml'
          )
        )
      )
      visit solr_document_path(id)

      expect(page).to have_link('Librarian View')
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

      expect(page).to have_css('h2', text: 'More Options')
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
        expect(page).not_to have_css('h2', text: 'More Options')
        expect(page).not_to have_link('Find more information about Books')
      end
    end
  end

  context 'Tools Menu card' do
    it 'show direct link for an object' do
      visit solr_document_path(id)

      expect(page).to have_link("Direct Link")
    end
  end
end
