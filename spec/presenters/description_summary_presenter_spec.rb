# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DescriptionSummaryPresenter do
  let(:pres) { described_class.new(document: TEST_ITEM) }
  let(:main_terms) do
    { finding_aid_url_ssim: ['http://www.example.com text: Finding Aid Text'],
      language_ssim: ['English'],
      material_type_display_tesim: ['1 online resource (111 pages)'],
      note_general_tsim: ['General note'],
      note_language_tesim: ['Language notes.'],
      note_local_tesim: ['A local note.'],
      note_participant_tesim: ['A note about a performer.'],
      note_production_tesim: ['Directed by Tim Burton.'],
      note_publication_dates_tesim: ['Began with: Vol. 1, no. 1 (Jan./Feb. 2009)'],
      note_publication_tesim: ['This is a Publication Note.'],
      note_technical_tesim: ['CDROM included.'],
      note_access_restriction_tesim: ['Open Access'],
      note_time_place_event_tesim: ['Filmed in Georgia, baby!'],
      note_use_tesim: ['This eBook is made available Open Access under a CC BY-NC-ND 4.0 license:'],
      summary_tesim: ['Short summary'],
      table_of_contents_tesim: ['1,2: Freddy\'s Coming For You'],
      url_suppl_ssim: ['http://www.example.com'],
      note_accessibility_tesim: ['A note on accessibility'],
      note_addl_form_tesim: ['Also available in print.'],
      note_arrangement_tesim: ['Concerto in B minor.'],
      note_reproduction_tesim: ['A note about this reproduction.'],
      note_historical_tesim: ['A historical note.'],
      note_location_originals_tesim: ['University of Tuscaloosie'],
      note_custodial_tesim: ['A note left by the janitor.'],
      note_copy_identification_tesim: ['Notes on versions.'],
      note_binding_tesim: ['Notes on binding.'],
      note_citation_tesim: ['Some notes on citations.'],
      note_related_collections_tesim: ['Notes on related collections.'] }
  end
  context 'with a solr document' do
    describe '#terms' do
      it 'has the correct terms' do
        expect(pres.terms).to eq(main_terms)
      end
    end
  end
end
