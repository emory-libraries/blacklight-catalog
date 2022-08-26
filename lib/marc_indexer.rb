# frozen_string_literal: true
$VERBOSE = nil
$LOAD_PATH.unshift './config'
require 'library_stdnums'
require 'traject'
require 'traject/null_writer'
require 'traject/solr_json_writer'
require 'traject/marc_reader'
require 'marc/fastxmlwriter'

# Traject Macros
require 'traject/macros/marc21.rb'
extend Traject::Macros::Marc21
# Pull in the standard marc21 semantics, to get stuff like
# 'marc_sortable_title'. 'marc_publication_date', etc.
require 'traject/macros/marc21_semantics'
extend Traject::Macros::Marc21Semantics
# Ditto with the opinionated format classifier;
# this gives you the 'marc_formats' macro
require 'traject/macros/marc_format_classifier'
extend Traject::Macros::MarcFormats

# Marc Indexer Formats
require 'blacklight/marc/indexer/formats'
extend Blacklight::Marc::Indexer::Formats

# Custom Method Toolbox Require
require 'traject/extraction_tools'

# Custom Method Requires
require 'traject/extract_author_addl_display'
require 'traject/extract_author_display'
require 'traject/extract_author_vern'
require 'traject/extract_bound_with_display'
require 'traject/extract_collection'
require 'traject/extract_emory_collection'
require 'traject/extract_finding_aid_url'
require 'traject/extract_format_string'
require 'traject/extract_isbn'
require 'traject/extract_other_standard_ids'
require 'traject/extract_call_number'
require 'traject/extract_emory_sortable_author'
require 'traject/extract_emory_sortable_title'
require 'traject/extract_library'
require 'traject/extract_marc_resource'
require 'traject/extract_publication_main_display.rb'
require 'traject/extract_publication_date'
require 'traject/extract_published'
require 'traject/extract_publisher_details_display'
require 'traject/extract_subject_display'
require 'traject/extract_subject'
require 'traject/extract_subject_geo'
require 'traject/extract_subject_era'
require 'traject/extract_genre'
require 'traject/extract_title_details_display'
require 'traject/extract_title_main_first_char'
require 'traject/extract_title_precise'
require 'traject/extract_url_fulltext'
require 'traject/extract_url_suppl'

# Custom Method Toolbox Extension
extend ExtractionTools

# Custom Method Extensions
extend ExtractAuthorAddlDisplay
extend ExtractAuthorDisplay
extend ExtractAuthorVern
extend ExtractBoundWithDisplay
extend ExtractCollection
extend ExtractEmoryCollection
extend ExtractFindingAidUrl
extend ExtractFormatString
extend ExtractIsbn
extend ExtractOtherStandardIds
extend ExtractCallNumber
extend ExtractEmorySortableAuthor
extend ExtractEmorySortableTitle
extend ExtractLibrary
extend ExtractMarcResource
extend ExtractPublicationMainDisplay
extend ExtractPublicationDate
extend ExtractPublished
extend ExtractPublisherDetailsDisplay
extend ExtractSubjectDisplay
extend ExtractSubjectEra
extend ExtractSubjectGeo
extend ExtractGenre
extend ExtractSubject
extend ExtractTitleDetailsDisplay
extend ExtractTitleMainFirstChar
extend ExtractTitlePrecise
extend ExtractUrlFulltext
extend ExtractUrlSuppl

# Variables used throughout indexing
ATOZ = ('a'..'z').to_a.join('').freeze
ATOU = ('a'..'u').to_a.join('').freeze
ATOG = ('a'..'g').to_a.join('').freeze
KTOS = ('k'..'s').to_a.join('').freeze
VTOZ = ('v'..'z').to_a.join('').freeze

# Override constant to include OCLC prefix
Traject::Macros::Marc21Semantics::OCLCPAT = /
  \A\s*
  (?:(?:\(OCoLC\)) |
     (?:\(OCoLC\))?(?:(?:ocm)|(?:ocn)|(?:on)|(?:OCLC))
     )(\d+)
     /x.freeze

settings do
  # type may be 'binary', 'xml', or 'json'
  provide "marc_source.type", "xml"
  provide 'solr_writer.max_skipped', 0
  provide "reader_class_name", "Traject::MarcReader"
  if (c = Blacklight.connection_config)
    provide "solr.url", c[:url]
  end
  provide "solr_writer.commit_on_close", "true"
  provide "solr_writer.thread_pool", 1
  provide "solr_writer.batch_size", 900
  provide "solr_writer.http_timeout", 240
  provide "writer_class_name", "Traject::SolrJsonWriter"
  provide 'processing_thread_pool', 1
  provide "log.batch_size", 10_000
end

# Total of 66 fields mapped

to_field "id", extract_marc("001"), trim, first_only

# Mass of Data Fields
to_field 'holdings_note_tesim', extract_marc('966a')
to_field 'marc_display_tesi', get_xml
to_field 'note_access_restriction_tesim', extract_marc('506a3')
to_field 'note_accessibility_tesim', extract_marc('532a:341abcde3')
to_field 'note_addl_form_tesim', extract_marc('530a3')
to_field 'note_arrangement_tesim', extract_marc('351ab')
to_field 'note_binding_tesim', extract_marc('563abcde3')
to_field 'note_citation_tesim', extract_marc('510abcx3')
to_field 'note_copy_identification_tesim', extract_marc('562abc')
to_field 'note_custodial_tesim', extract_marc('561a')
to_field 'note_general_tsim', extract_marc('500a')
to_field 'note_historical_tesim', extract_marc('545a')
to_field 'note_local_tesim', extract_marc('590a')
to_field 'note_location_originals_tesim', extract_marc('535a3')
to_field 'note_participant_tesim', extract_marc('511a')
to_field 'note_production_tesim', extract_marc('508a')
to_field 'note_publication_tesim', extract_marc('581a3')
to_field 'note_related_collections_tesim', extract_marc('544n')
to_field 'note_reproduction_tesim', extract_marc('533a3')
to_field 'note_technical_tesim', extract_marc('538a')
to_field 'note_time_place_event_tesim', extract_marc('518adop')
to_field 'note_use_tesim', extract_marc('540a3')
to_field 'summary_tesim', extract_marc('520a')
to_field 'table_of_contents_tesim', extract_marc('505agrt')
to_field "text_tesi", extract_all_marc_values(from: '010', to: '899') do |_r, acc|
  acc.replace [acc.join(' ')] # turn it into a single string
end

# Language Fields
to_field "language_ssim", marc_languages('008[35-37]:041a:041d')
to_field "language_tesim", marc_languages('008[35-37]:041a:041d')
to_field "note_language_tesim", extract_marc('546ab3')

# Type Fields
to_field "format_ssim", extract_format_string
to_field 'marc_resource_ssim', extract_marc_resource
to_field 'material_type_display_tesim', extract_marc('300abcef'), trim_punctuation

# Various Identification Fields
to_field "isbn_ssim", extract_isbn
to_field 'issn_ssim', extract_marc('022a:022y:800x:810x:811x:830x')
to_field 'lccn_ssim', extract_marc('010a')
to_field 'oclc_ssim', oclcnum('019a:035a')
to_field 'other_standard_ids_tesim', extract_other_standard_ids
to_field 'local_call_number_tesim', extract_call_number

# Title Fields
#    Primary Title
to_field 'title_citation_ssi', extract_marc('245abnp'), trim_punctuation, first_only
to_field 'title_tesim', extract_marc('245a')
to_field 'title_vern_display_tesim', extract_marc('245abfgknps', alternate_script: :only), trim_punctuation

#    Additional Title Fields
to_field 'title_abbr_tesim', extract_marc('210ab')
to_field 'title_added_entry_tesim', extract_marc(title_added_entry_tesim_str)
to_field 'title_addl_tesim', extract_marc("245#{ATOG}knps"), trim_punctuation
to_field 'title_enhanced_tesim', extract_marc("505#{ATOZ}")
to_field 'title_former_ssim', extract_marc('247abcdefgnp:780abcdgikmnorstuwxyz')
to_field 'title_former_tesim', extract_marc('247abcdefgnp')
to_field 'title_host_item_tesim', extract_marc("773#{ATOZ}:774#{ATOZ}")
to_field 'title_key_tesim', extract_marc('222ab')
to_field 'title_later_ssim', extract_marc('785abcdgikmnorstuxyz')
to_field 'title_later_tesim', extract_marc('785abcdgikmnorstuxyz')
to_field 'title_main_display_ssim', extract_marc('245abfgknps', alternate_script: false), trim_punctuation
to_field 'title_main_first_char_ssim', extract_title_main_first_char
to_field 'title_precise_tesim', extract_title_precise
to_field 'title_series_ssim', extract_marc(title_series_str(ATOG))
to_field 'title_series_tesim', extract_marc(title_series_str(ATOG))
to_field 'title_ssort', extract_emory_sortable_title
to_field 'title_translation_tesim', extract_marc("242#{ATOZ}")
to_field 'title_uniform_ssim', extract_marc("130adfklmnoprs:240#{ATOG}knps")
to_field 'title_varying_tesim', extract_marc("246#{ATOG}inp")

# Author Fields
to_field 'author_addl_display_tesim', extract_author_addl_display
to_field 'author_addl_ssim', extract_marc("700abcdgqt:710abcdgn:711acdegnqe", alternate_script: false), trim_punctuation
to_field 'author_display_ssim', extract_author_display
# JSTOR isn't an author. Try to not use it as one
to_field 'author_ssort', extract_emory_sortable_author
to_field 'author_ssim', extract_marc("100abcdq:110abd:111acd:700abcdq:710abd:711acd"), trim_punctuation
to_field 'author_tesim', extract_marc("100abcegqu:110abcdegnu:111acdegjnqu")
to_field 'author_vern_ssim', extract_author_vern
to_field 'author_vern_tesim', extract_author_vern

# Subject Fields
to_field 'subject_display_ssim', extract_subject_display
to_field 'subject_era_ssim',  extract_subject_era
to_field 'subject_geo_ssim',  extract_subject_geo
to_field 'subject_ssim', extract_subject, trim_punctuation
to_field 'subject_tesim', extract_marc(subject_tesim_str(ATOZ))

# Genre Fields
to_field 'genre_ssim', extract_genre

# Publication Fields
to_field 'note_publication_dates_tesim', extract_marc('362a')
to_field 'pub_date_isim', extract_publication_date
to_field 'publication_main_display_ssim', extract_publication_main_display
to_field 'published_tesim', extract_published
to_field 'published_vern_ssim', extract_marc('260a', alternate_script: :only), trim_punctuation
to_field 'publisher_details_display_ssim', extract_publisher_details_display
to_field 'publisher_location_ssim', extract_marc("260a:264a"), trim_punctuation
to_field 'publisher_number_tesim', extract_marc('028ab')

# Library of Congress Fields
to_field 'lc_1letter_ssim', extract_marc('050a:090a'), first_letter, translation_map('callnumber_map')
to_field 'lc_alpha_ssim', extract_marc('050a'), alpha_only, first_only
to_field 'lc_b4cutter_ssim', extract_marc('050a'), first_only
to_field 'lc_callnum_ssim', extract_marc('050ab'), first_only

# URL Fields
to_field 'finding_aid_url_ssim', extract_finding_aid_url
to_field 'url_fulltext_ssm', extract_url_fulltext
to_field 'url_suppl_ssim', extract_url_suppl

# Library Fields
to_field 'library_ssim', extract_library, translation_map('libraryname_map')

# Collection Fields
to_field 'bound_with_display_ssim', extract_bound_with_display
to_field 'collection_ssim', extract_collection
to_field 'edition_tsim', extract_marc('250a:254a')
to_field 'emory_collection_tesim', extract_emory_collection
