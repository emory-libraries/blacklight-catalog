# frozen_string_literal: true

module OaiProcessingToolset
  MARC_URL = { 'marc' => "http://www.loc.gov/MARC21/slim" }.freeze
  OAI_URL = { 'oai' => 'http://www.openarchives.org/OAI/2.0/' }.freeze

  def ingest_with_traject(filename, logger)
    indexer = Traject::Indexer::MarcIndexer.new("solr_writer.commit_on_close": true, logger: logger)
    indexer.load_config_file(Rails.root.join('lib', 'marc_indexer.rb').to_s)
    indexer.process(filename)
  rescue => e
    logger.fatal e
  end

  def oai_to_marc
    %q(<?xml version='1.0'?>
         <xsl:stylesheet version="1.0"
         xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
         xmlns:oai="http://www.openarchives.org/OAI/2.0/"
         xmlns:marc="http://www.loc.gov/MARC21/slim">
           <xsl:template match="/">
             <collection>
             <xsl:for-each select="oai:OAI-PMH/oai:ListRecords/oai:record">
               <xsl:copy-of select="oai:metadata/marc:record"/>
             </xsl:for-each>
           </collection>
         </xsl:template>
         </xsl:stylesheet>)
  end

  def pull_deleted_ids(deleted_records, logger)
    ids = deleted_records.map { |n| n.at('header/identifier').text.split(':').last }
    logger.info "Deleted IDs: #{ids}"
    ids
  end

  def pull_suppressed_ids(suppressed_records, logger)
    # collects ID from controlfield 001
    ids = suppressed_records.map { |s| s.at_xpath("marc:controlfield[@tag='001']", MARC_URL).text }
    logger.info("Suppressed IDs: #{ids}")
    ids
  end

  def pull_lost_stolen_ids(lost_stolen_records, suppressed_ids, logger)
    # collects ID from controlfield 001
    ids = lost_stolen_records.map { |s| s.at_xpath("marc:controlfield[@tag='001']", MARC_URL).text } - suppressed_ids
    logger.info("Lost/Stolen IDs: #{ids}")
    ids
  end

  def pull_record_count(document, logger)
    active_ids_xpath = '/oai:OAI-PMH/oai:ListRecords/oai:record/oai:metadata/marc:record/marc:controlfield[@tag="001"]'
    ids = document.xpath(active_ids_xpath, OAI_URL.dup.merge(MARC_URL)).map(&:content)
    logger.info "#{ids.size} records retrieved"
    logger.info "Active IDs: #{ids}"
    ids.size
  end

  def call_oai_for_xml(alma, institution, qs, logger)
    oai_base = "https://#{alma}.alma.exlibrisgroup.com/view/oai/#{institution}/request"
    oai_connection = Faraday.new do |f|
      f.request :retry, { max: 10, interval: 30, interval_randomness: 0.75, backoff_factor: 2 }
    end
    oai_connection.options.timeout = 240

    logger.info "Calling OAI with query string: #{qs}"
    oai_connection.get oai_base + qs
  rescue => err
    ["Communication with the OAI Service failed.", err].each { |m| logger.fatal(m) }
  end

  def pull_lost_stolen_records(document)
    document.xpath('//marc:record', MARC_URL).select do |d|
      hol852_count = d.xpath("marc:datafield[@tag='HOL852']", MARC_URL).size
      holsp_count = d.xpath(
        "marc:datafield[@tag='HOLSP']//marc:subfield[@code='a'][text()='true']", MARC_URL
      ).size
      hol852_count.positive? && hol852_count <= holsp_count
    end
  end

  def pull_deactivated_portfolios(document)
    document.xpath('//marc:record', MARC_URL).select do |d|
      nine_nine_eight_count = get_998_count(d)
      eight_five_six_count = d.xpath("marc:datafield[@tag='856']", MARC_URL).size
      physical = document_contain_physical?(d)
      deactivate_portfolios_count = get_deact_port_count(d)

      !physical && deactivate_portfolios_count.positive? &&
        nine_nine_eight_count + eight_five_six_count <= deactivate_portfolios_count
    end
  end

  def pull_deactivated_portfolios_ids(deactivated_portfolios, suppressed_ids, logger)
    ids = deactivated_portfolios.map { |dp| dp.at_xpath("marc:controlfield[@tag='001']", MARC_URL).text } - suppressed_ids
    logger.info("Deactivated Portfolio IDs: #{ids}")
    ids
  end

  def get_998_count(document)
    document.xpath(
      "marc:datafield[@tag='998']//marc:subfield[@code='c'][text()='available']", MARC_URL
    ).size
  end

  def document_contain_physical?(document)
    !document.xpath(
      "marc:datafield[@tag='997']//marc:subfield[@code='b']", MARC_URL
    ).empty?
  end

  def get_deact_port_count(document)
    document.xpath(
      "marc:datafield[@tag='998']//marc:subfield[@code='e'][text()='Not Available']", MARC_URL
    ).size
  end
end
