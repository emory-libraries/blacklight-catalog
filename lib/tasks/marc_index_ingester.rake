# frozen_string_literal: true

desc "Harvest OAI XML denoted in ENV oai_set_name and index in Solr via Traject"
task marc_index_ingest: [:environment] do
  oai_set = ENV['oai_set_name']
  abort 'The ENV variable oai_set_name has not been set.' if oai_set.blank?

  log "Starting..."

  from_time = PropertyBag.get('marc_ingest_time')
  log "Setting 'from' time: #{from_time}"
  from_time = "&from=#{from_time}" if from_time

  to_time = Time.new.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
  log "Set 'to' time: #{to_time}"

  # check where to resume harvesting from
  saved_resumption_token = PropertyBag.get('marc_ingest_resumption_token')

  qs = if !saved_resumption_token.to_s == ''
         # resume from last harvested
         "?verb=ListRecords&resumptionToken=#{saved_resumption_token}"
       else
         # start fresh harvest
         "?verb=ListRecords&set=#{oai_set}&metadataPrefix=marc21&until=#{to_time}#{from_time}"
       end

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
  time = Time.new.utc
  time = time.strftime("%Y-%m-%d %H:%M:%S")
  puts "#{time} - #{msg}"
  true
end
