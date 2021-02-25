# frozen_string_literal: true

class OaiQueryStringService
  def self.process_query_string(oai_set, full_index, to_time)
    from_time = process_from_time(full_index)
    # check where to resume harvesting from
    saved_resumption_token = PropertyBag.get('marc_ingest_resumption_token')

    process_string(saved_resumption_token, oai_set, from_time, to_time)
  end

  def self.process_from_time(full_index)
    from_time = full_index ? nil : PropertyBag.get('marc_ingest_time')
    log "Setting 'from' time: #{from_time}"
    from_time = "&from=#{from_time}" if from_time
    from_time
  end

  def self.process_string(saved_resumption_token, oai_set, from_time, to_time)
    # resume from last harvested
    return "?verb=ListRecords&resumptionToken=#{saved_resumption_token}" if saved_resumption_token.present?
    # start fresh harvest
    "?verb=ListRecords&set=#{oai_set}&metadataPrefix=marc21&until=#{to_time}#{from_time}"
  end

  def self.log(msg)
    time = Time.new.utc.strftime("%Y-%m-%d %H:%M:%S")
    puts "#{time} - #{msg}"
    true
  end
end
