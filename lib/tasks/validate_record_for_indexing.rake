# frozen_string_literal: true

# To use the follwing rake task, run the following:
# bundle exec rails validate_record_for_indexing record_id=RECORD_ID

desc "Validate if a record should be indexed in Solr"
task validate_record_for_indexing: [:environment] do
  logger = Logger.new(STDOUT)
  record_id = ENV['record_id'].to_i
  begin
    OaiValidationService.validate_record!(record_id)
    logger.info "Record ##{record_id} is valid for indexing."
  rescue => e
    logger.error "Record ##{record_id} is not valid for indexing for the following reason: #{e.message}"
  end
end
