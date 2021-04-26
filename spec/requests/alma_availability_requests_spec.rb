# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Alma Availability requests', type: :request do
  let(:id) { '990005988630302486' }
  let(:id2) { '990005059530302486' }
  let(:expected_json) do
    {
      "990005988630302486": {
        "physical": {
          "library": "Rose Library (MARBL) (Library Service Center)",
          "call_number": "PT2613 .M45 Z92 2006",
          "available": '<span class="item-available">Available</span>'
        }
      }
    }.to_json
  end
  let(:expected_json2) do
    {
      "990005059530302486": {
        "physical": {
          "library": "Multiple libraries/locations",
          "call_number": "-",
          "available": '<span class="item-available">One or more copies available</span>'
        }
      }
    }.to_json
  end
  before do
    delete_all_documents_from_solr
    build_solr_docs(
      [
        TEST_ITEM.merge(
          id: id,
          library_ssim: 'Rose Library (MARBL)'
        ),
        TEST_ITEM.merge(
          id: id2
        )
      ]
    )
  end

  it 'returns the right json when subfield==q is Library Service Center' do
    get '/alma_availability/' + id + '.json'

    expect(response.body).to eq(expected_json)
  end

  it 'returns the right json when there are multiple copies across different libraries' do
    get '/alma_availability/' + id2 + '.json'

    expect(response.body).to eq(expected_json2)
  end
end
