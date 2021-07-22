# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UpdateCollectionAuthorityService do
  around do |example|
    ENV['SOLR_URL'] = "http://example.com/solr/blacklight-test"
    example.run
    ENV['SOLR_URL'] = ""
  end

  before do
    stub_request(:get, "http://example.com/solr/blacklight-test/select?fl=collection_ssim&facet.field=collection_ssim&facet.limit=-1&facet=true")
      .to_return(status: 200, body: File.read(fixture_path + '/collection_ssim_query_response.json'), headers: {})
  end

  it "sends get request and pulls in collections from response body" do
    described_class.update_authority_entries
    expect(Qa::LocalAuthority.all.pluck(:name)).to include 'collections'
    expect(Qa::LocalAuthorityEntry.count).to eq 1
    expect(Qa::LocalAuthorityEntry.all.pluck(:uri)).to include '--For example'
  end
end
