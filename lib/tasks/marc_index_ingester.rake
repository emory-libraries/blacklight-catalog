# frozen_string_literal: true

desc "Harvest OAI XML denoted in ENV oai_set_name and index in Solr via Traject"
task marc_index_ingest: [:environment] do
  oai_set = ENV['oai_single_id'] || ENV['oai_set_name']
  full_index = ENV['full_index'].present?
  to_time = Time.new.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
  single_record = ENV.key?('oai_single_id') ? true : false

  # Language filter logging
  language_filter_log_path = Rails.root.join('tmp', 'language_filter.log')
  File.open(language_filter_log_path, 'w') do |file|
    file.truncate(0)
  end

  ingest_logger = Logger.new("marc_ingest_#{Time.new.utc.strftime('%Y%m%dT%H%M')}.log") unless single_record

  abort 'The ENV variable oai_set_name or oai_single_id has not been set.' if oai_set.blank?

  qs = OaiQueryStringService.process_query_string(oai_set, full_index, to_time, single_record)
  ingest_logger&.info("Set 'to' time: #{to_time}")

  counter = 1

  loop do
    # expect resumption token to be returned from process_oai method, else
    # it will be set to blank
    if single_record
      resumption_token = OaiProcessingService.process_oai_with_marc_indexer(ENV['INSTITUTION'], qs, ENV['ALMA'], true)
      qs = "?verb=GetRecord&resumptionToken=#{resumption_token}"
    else
      ingest_logger.info "Batch ##{counter}, query string: #{qs}"
      resumption_token = OaiProcessingService.process_oai_with_marc_indexer(ENV['INSTITUTION'], qs, ENV['ALMA'], false, ingest_logger)
      qs = "?verb=ListRecords&resumptionToken=#{resumption_token}"
      counter += 1
    end
    PropertyBag.set('marc_ingest_resumption_token', resumption_token)
    break if resumption_token == ''
  end

  # save to date for next time
  ingest_logger&.info("Storing 'to' time")
  PropertyBag.set('marc_ingest_time', to_time) unless single_record

  ingest_logger&.info("Ingesting Complete!")
end
