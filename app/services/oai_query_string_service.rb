# frozen_string_literal: true

class OaiQueryStringService
  def self.process_query_string(oai_set, full_index, to_time, single_record, logger)
    from_time = process_from_time(full_index, logger)
    processed_to_time = process_to_time(to_time, full_index, logger)
    # check where to resume harvesting from
    saved_resumption_token = PropertyBag.get('marc_ingest_resumption_token')

    process_string(saved_resumption_token, oai_set, from_time, processed_to_time, single_record)
  end

  def self.process_from_time(full_index, logger)
    from_time = full_index ? nil : PropertyBag.get('marc_ingest_time')
    logger.info "Setting 'from' time: #{from_time}"
    from_time = "&from=#{from_time}" if from_time
    from_time
  end

  def self.process_to_time(to_time, full_index, _logger)
    return "&until=#{to_time}" if to_time.present? && !full_index
    ''
  end

  def self.process_string(saved_resumption_token, oai_set, from_time, to_time, single_record)
    # resume from last harvested
    return "?verb=ListRecords&resumptionToken=#{saved_resumption_token}" if saved_resumption_token.present?
    # start a single record harvest
    return "?verb=GetRecord&identifier=oai:alma.#{ENV['INSTITUTION']}:#{oai_set}&metadataPrefix=marc21" if single_record
    # start a fresh set harvest
    "?verb=ListRecords&set=#{oai_set}&metadataPrefix=marc21#{to_time}#{from_time}"
  end
end
