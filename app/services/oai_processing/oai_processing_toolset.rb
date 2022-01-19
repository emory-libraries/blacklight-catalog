# frozen_string_literal: true

module OaiProcessingToolset
  MARC_URL = { 'marc' => "http://www.loc.gov/MARC21/slim" }.freeze
  OAI_URL = { 'oai' => 'http://www.openarchives.org/OAI/2.0/' }.freeze
  ALL_LIB_LOCATIONS = ['WD', 'XM', 'XL', 'SP'].freeze
  LIB_LOC_PAIRS = [['LAW', 'DISP'], ['MUSME', 'DUC1'], ['MUSME', 'DUC2'],
                   ['THEO', 'EXHIBIT'], ['THEO', 'SPSTOR'], ['THEO', 'STORP'],
                   ['UNIV', '24EQUIP'], ['UNIV', '3DEQUIP'], ['UNIV', '3HEQUIP'],
                   ['UNIV', '3HLAP'], ['UNIV', '7DEQUIP'], ['UNIV', 'BRITTLE'],
                   ['UNIV', 'FLIP'], ['UNIV', 'SDL'], ['UNIV', 'STUDIO'], ['UNIV', 'UMBR'],
                   ['HLTH', 'LKEY']].freeze

  def ingest_with_traject(filename, logger)
    indexer = Traject::Indexer::MarcIndexer.new("solr_writer.commit_on_close": true, logger: logger)
    indexer.load_config_file(Rails.root.join('lib', 'marc_indexer.rb').to_s)
    indexer.process(filename)
  rescue => e
    logger.fatal e
  end

  def oai_to_marc(xml_type)
    %(<?xml version='1.0'?>
         <xsl:stylesheet version="1.0"
         xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
         xmlns:oai="http://www.openarchives.org/OAI/2.0/"
         xmlns:marc="http://www.loc.gov/MARC21/slim">
           <xsl:template match="/">
             <collection>
             <xsl:for-each select="oai:OAI-PMH/oai:#{xml_type}/oai:record">
               <xsl:copy-of select="oai:metadata/marc:record"/>
             </xsl:for-each>
           </collection>
         </xsl:template>
         </xsl:stylesheet>)
  end

  def pull_record_count(document, xml_type, logger)
    active_ids_xpath = "/oai:OAI-PMH/oai:#{xml_type}/oai:record/oai:metadata/marc:record/marc:controlfield[@tag='001']"
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

  def get_998_count(document)
    document.xpath("marc:datafield[@tag='998']", MARC_URL).size
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
