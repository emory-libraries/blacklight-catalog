# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Alma Availability requests', type: :request do
  let(:id) { '990005988630302486' }
  let(:id2) { '990005059530302486' }

  it 'returns the right json (example #1)' do
    get '/alma_availability/' + id + '.json'

    expect(response.body).to eq(
      '{"990005988630302486":{"physical":{"exists":true,"available":true},"online":{"exists":true}}}'
    )
  end

  it 'returns the right json (example #2)' do
    get '/alma_availability/' + id2 + '.json'

    expect(response.body).to eq(
      '{"990005059530302486":{"physical":{"exists":true,"available":true},"online":{"exists":false}}}'
    )
  end
end
