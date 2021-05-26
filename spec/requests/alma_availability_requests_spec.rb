# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Alma Availability requests', type: :request, alma: true do
  let(:id) { '990005988630302486' }
  let(:id2) { '990005059530302486' }
  let(:expected_json) do
    {
      "990005988630302486": {
        "physical": {
          "library": "Rose Library (MARBL) (Library Service Center)",
          "call_number": "PT2613 .M45 Z92 2006",
          "available": '<span class="item-available">Available</span>'
        },
        "online": {
          "links": [{ "http://www.example2.com": "Link Text for Book" }],
          "uresolver": false
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
        },
        "online": {
          "links": [{ "http://www.example2.com": "Link Text for Book" }],
          "uresolver": false
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

  around do |example|
    orig_url = ENV['ALMA_API_URL']
    orig_key = ENV['ALMA_BIB_KEY']
    ENV['ALMA_API_URL'] = 'www.example.com'
    ENV['ALMA_BIB_KEY'] = "fakebibkey123"
    example.run
    ENV['ALMA_API_URL'] = orig_url
    ENV['ALMA_BIB_KEY'] = orig_key
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
