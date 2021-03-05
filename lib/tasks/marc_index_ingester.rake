# frozen_string_literal: true

desc "Harvest OAI XML denoted in ENV oai_set_name and index in Solr via Traject"
task marc_index_ingest: [:environment] do
  oai_set = ENV['oai_set_name'] || ENV['oai_single_id']
  full_index = ENV['full_index'].present?
  to_time = Time.new.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
  single_record = ENV.key?('oai_single_id') ? true : false
  abort 'The ENV variable oai_set_name or oai_single_id has not been set.' if oai_set.blank?

  log "Starting..."

  qs = OaiQueryStringService.process_query_string(oai_set, full_index, to_time, single_record)
  log "Set 'to' time: #{to_time}"

  loop do
    # expect resumption token to be returned from process_oai method, else
    # it will be set to blank
    resumption_token = OaiProcessingService.process_oai_with_marc_indexer(ENV['INSTITUTION'], qs, ENV['ALMA'])
    qs = "?verb=ListRecords&resumptionToken=#{resumption_token}"
    PropertyBag.set('marc_ingest_resumption_token', resumption_token)
    break if resumption_token == ''
  end

  # save to date for next time
  log "Storing 'to' time"
  PropertyBag.set('marc_ingest_time', to_time)

  log "Complete!"
end

def log(msg)
  time = Time.new.utc.strftime("%Y-%m-%d %H:%M:%S")
  puts "#{time} - #{msg}"
  true
end
