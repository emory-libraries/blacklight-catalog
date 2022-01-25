# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OaiValidationService, :clean do
  let(:logger) { instance_double(Logger, "logger", info: nil, debug: nil) }
  PropertyBag.set('marc_ingest_resumption_token', '')
  PropertyBag.set('marc_ingest_time', '2021-02-23T21:32:25Z')

  before do
    stub_const('ENV', ENV.to_hash.merge({ 'INSTITUTION' => 'emory', 'ALMA' => 'emory_alma_example' }))
  end

  describe '#validate_record!' do
    context 'when record is valid' do
      it 'returns true' do
        stub_request(:get, "https://emory_alma_example.alma.exlibrisgroup.com/view/oai/emory/request?identifier=oai:alma.emory:990000954720302486&metadataPrefix=marc21&verb=GetRecord")
          .to_return(status: 200, body: File.read(fixture_path + '/single_record.xml'), headers: {})
        expect(described_class.validate_record!(990_000_954_720_302_486, logger)).to eq(true)
      end
    end

    context 'when record is not valid' do
      it 'raises an error' do
        stub_request(:get, "https://emory_alma_example.alma.exlibrisgroup.com/view/oai/emory/request?identifier=oai:alma.emory:990000954720302486&metadataPrefix=marc21&verb=GetRecord")
          .to_return(status: 200, body: File.read(fixture_path + '/single_record_deleted.xml'), headers: {})
        expected_error_message = "Record #990000954720302486 violates the following rule: Remove all records that were deleted."
        expect { described_class.validate_record!(990_000_954_720_302_486, logger) }.to raise_error(OaiValidationServiceError, expected_error_message)
      end
    end
  end
end
