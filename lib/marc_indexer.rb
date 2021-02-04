# frozen_string_literal: true
$LOAD_PATH.unshift './config'
require 'library_stdnums'
require 'traject'
require 'traject/null_writer'

require 'traject/solr_json_writer'
require 'traject/marc_reader'
require 'marc/fastxmlwriter'
require 'traject/macros/marc21.rb'
extend Traject::Macros::Marc21

require 'blacklight/marc/indexer/formats'
extend Blacklight::Marc::Indexer::Formats

# Pull in the standard marc21 semantics, to get stuff like
# 'marc_sortable_title'. 'marc_publication_date', etc.
require 'traject/macros/marc21_semantics'
extend Traject::Macros::Marc21Semantics

# Ditto with the opinionated format classifier;
# this gives you the 'marc_formats' macro
require 'traject/macros/marc_format_classifier'
extend Traject::Macros::MarcFormats

ATOZ = ('a'..'z').to_a.join('')
ATOU = ('a'..'u').to_a.join('')
ATOG = ('a'..'g').to_a.join('')
KTOS = ('k'..'s').to_a.join('')

settings do
  # type may be 'binary', 'xml', or 'json'
  provide "marc_source.type", "xml"
  provide 'solr_writer.max_skipped', -1
  provide "reader_class_name", "Traject::MarcReader"
  if (c = Blacklight.connection_config)
    provide "solr.url", c[:url]
  end
  provide "solr_writer.commit_on_close", "true"
  provide "solr_writer.thread_pool", 1
  provide "solr_writer.batch_size", 100
  provide "writer_class_name", "Traject::SolrJsonWriter"
  provide 'processing_thread_pool', 1
  provide "log.batch_size", 10_000
end

def trim
  lambda do |_record, accumulator|
    accumulator.each(&:strip!)
  end
end

def get_xml(_options = {})
  lambda do |record, accumulator|
    accumulator << MARC::FastXMLWriter.encode(record)
  end
end

to_field "id", extract_marc("001"), trim, first_only
to_field 'marc_display_tesi', get_xml
to_field "text_tesi", extract_all_marc_values(from: '010', to: '899') do |_r, acc|
  acc.replace [acc.join(' ')] # turn it into a single string
end
to_field "language_facet_tesim", marc_languages('008[35-37]:041a:041d')
to_field 'marc_resource_ssim' do |rec, acc|
  physical_present = rec.fields('997').present?
  electronic_present = rec.fields('998').present?
  form_item_data = rec.fields('008').present? ? rec.fields('008')[0].value[29] : ""
  accomp_data = rec.fields('008').present? ? rec.fields('008')[0].value[23] : ""
  leader_formats = ['e', 'f', 'g', 'k', 'o', 'r'].any? { |l| rec.leader[6] == l }
  form_of_item = ['o', 's'].any? { |l| form_item_data == l }
  accomp_matter = ['o', 's'].any? { |l| accomp_data == l }

  acc << "Physical Resource" if physical_present
  acc << "Electronic Resource" if electronic_present

  if !physical_present && !electronic_present
    acc << "Electronic Resource" if leader_formats && form_of_item
    acc << "Physical Resource" if leader_formats && !form_of_item
    acc << "Electronic Resource" if !leader_formats && accomp_matter
    acc << "Physical Resource" if !leader_formats && !accomp_matter
  end
end

to_field "format_ssim" do |rec, acc|
  format_map_ldr_six = {
    'c' => "Musical Score", 'd' => "Musical Score", 'e' => "Map", 'f' => "Map", 'g' => "Visual Material",
    'i' => "Sound Recording", 'j' => "Sound Recording", 'k' => "Visual Material", 'm' => "Computer File",
    'o' => "Visual Material", 'p' => "Mixed Materials", 'r' => "Visual Material"
  }
  format_map_ldr_six_seven = {
    'aa' => "Book", 'ab' => "Serial", 'ac' => "Book", 'ad' => "Book", 'ai' => "Serial", 'am' => "Book",
    'as' => "Serial", 'ta' => "Book", 'tb' => "Serial", 'tc' => "Book", 'td' => "Book", 'ti' => "Serial",
    'tm' => "Book", 'ts' => "Serial"
  }

  acc << format_map_ldr_six[rec.leader[6].to_s] if format_map_ldr_six.keys.any?(rec.leader[6])

  acc << format_map_ldr_six_seven[rec.leader[6, 2].to_s] if format_map_ldr_six_seven.keys.any?(rec.leader[6, 2])
end

to_field "isbn_ssim", extract_marc('020a', separator: nil) do |_rec, acc|
  orig = acc.dup
  acc.map! { |x| StdNum::ISBN.allNormalizedValues(x) }
  acc << orig
  acc.flatten!
  acc.uniq!
end
to_field 'issn_ssim', extract_marc('022ay')
to_field 'lccn_ssim', extract_marc('010a')
to_field 'oclc_ssim', oclcnum('019a:035a')
to_field 'other_standard_ids_ssim', extract_marc('024a')
to_field 'publisher_number_ssim', extract_marc('028a')
to_field 'material_type_display_tesim', extract_marc('300a'), trim_punctuation

# Title fields
#    primary title
to_field 'title_tesim', extract_marc('245a')
to_field 'title_display_tesim', extract_marc('245a', alternate_script: false), trim_punctuation
to_field 'title_display_partnumber_tesim', extract_marc('245n'), trim_punctuation
to_field 'title_display_partname_tesim', extract_marc('245p'), trim_punctuation
to_field 'title_vern_display_tesim', extract_marc('245a', alternate_script: :only), trim_punctuation

#    subtitle
to_field 'subtitle_t', extract_marc('245b')
to_field 'subtitle_display_tesim', extract_marc('245b', alternate_script: false), trim_punctuation
to_field 'subtitle_vern_display_tesim', extract_marc('245b', alternate_script: :only), trim_punctuation

#    additional title fields
to_field 'title_abbr_tesim', extract_marc('210ab')
to_field 'title_addl_tesim', extract_marc(%W[
  130#{ATOZ}
  210ab
  222ab
  240#{ATOG}#{KTOS}
  242abnp
  243#{ATOG}#{KTOS}
  245abnps
  246#{ATOG}np
  247#{ATOG}np
].join(':'))
to_field 'title_added_entry_tesim', extract_marc(%w[
  700gklmnoprst
  710fgklmnopqrst
  711fgklnpst
  730abcdefgklmnopqrst
  740anp
].join(':'))
to_field 'title_enhanced_tesim', extract_marc(
  "505#{ATOZ}"
)
to_field 'title_former_tesim', extract_marc('247abcdefgnp')
to_field 'title_graphic_tesim', extract_marc("880#{ATOZ}")
to_field 'title_host_item_tesim', extract_marc("773#{ATOZ}:774#{ATOZ}")
to_field 'title_key_tesi', extract_marc('222ab'), first_only
to_field 'title_series_ssim', extract_marc(%W[
  440anpv
  490av
  800#{ATOZ}
  810#{ATOZ}
  811#{ATOZ}
  830#{ATOZ}
  840#{ATOZ}
].join(':'))
to_field 'title_ssort', marc_sortable_title
to_field 'title_translation_tesim', extract_marc("242#{ATOZ}:505t:740#{ATOZ}")
to_field 'title_varying_tesim', extract_marc("246#{ATOG}np")

# Author fields
to_field 'author_tesim', extract_marc("100abcegqu:110abcdegnu:111acdegjnqu")
to_field 'author_display_ssim', extract_marc("100abcdq:110#{ATOZ}:111#{ATOZ}")
to_field 'author_addl_tesim', extract_marc("700abcegqu:710abcdegnu:711acdegjnqu")
to_field 'author_ssm', extract_marc("100abcdq:110#{ATOZ}:111#{ATOZ}", alternate_script: false)
to_field 'author_vern_ssim', extract_marc("100abcdq:110#{ATOZ}:111#{ATOZ}", alternate_script: :only)

# JSTOR isn't an author. Try to not use it as one
to_field 'author_si', marc_sortable_author

# Subject fields
to_field 'subject_tsim', extract_marc(%W[
  600#{ATOU}
  610#{ATOU}
  611#{ATOU}
  630#{ATOU}
  650abcde
  651ae
  653a:654abcde:655abc
].join(':'))
to_field 'subject_addl_tsim', extract_marc("600vwxyz:610vwxyz:611vwxyz:630vwxyz:650vwxyz:651vwxyz:654vwxyz:655vwxyz")
to_field 'subject_ssim', extract_marc("600abcdq:610ab:611ab:630aa:650aa:653aa:654ab:655ab"), trim_punctuation
to_field 'subject_era_ssim',  extract_marc("650y:651y:654y:655y"), trim_punctuation
to_field 'subject_geo_ssim',  extract_marc("651a:650z"), trim_punctuation

# Publication fields
to_field 'published_ssm', extract_marc('260a', alternate_script: false), trim_punctuation
to_field 'published_vern_ssm', extract_marc('260a', alternate_script: :only), trim_punctuation
to_field 'publisher_location_ssm', extract_marc("260a:264a:008[15-17]"), trim_punctuation
to_field 'pub_date_si', marc_publication_date
to_field 'pub_date_ssim', marc_publication_date

# Call Number fields
to_field 'lc_callnum_ssm', extract_marc('050ab'), first_only

first_letter = ->(_rec, acc) { acc.map! { |x| x[0] } }
to_field 'lc_1letter_ssim', extract_marc('050ab'), first_only, first_letter, translation_map('callnumber_map')

alpha_pat = /\A([A-Z]{1,3})\d.*\Z/
alpha_only = lambda do |_rec, acc|
  acc.map! do |x|
    (m = alpha_pat.match(x)) ? m[1] : nil
  end
  acc.compact! # eliminate nils
end
to_field 'lc_alpha_ssim', extract_marc('050a'), alpha_only, first_only

to_field 'lc_b4cutter_ssim', extract_marc('050a'), first_only

to_field 'edition_tsim', extract_marc('250a')

to_field 'note_general_tsim', extract_marc('500a')

to_field 'summary_tesi', extract_marc('520a')

# URL Fields

notfulltext = /abstract|description|sample text|table of contents|/i

to_field('url_fulltext_ssm') do |rec, acc|
  rec.fields('856').each do |f|
    case f.indicator2
    when '0'
      f.find_all { |sf| sf.code == 'u' }.each do |url|
        acc << url.value
      end
    when '2'
      # do nothing
    else
      z3 = [f['z'], f['3']].join(' ')
      unless notfulltext.match?(z3)
        acc << f['u'] unless f['u'].nil?
      end
    end
  end
end

# Very similar to url_fulltext_display. Should DRY up.
to_field 'url_suppl_ssm' do |rec, acc|
  rec.fields('856').each do |f|
    case f.indicator2
    when '2'
      f.find_all { |sf| sf.code == 'u' }.each do |url|
        acc << url.value
      end
    when '0'
      # do nothing
    else
      z3 = [f['z'], f['3']].join(' ')
      if notfulltext.match?(z3)
        acc << f['u'] unless f['u'].nil?
      end
    end
  end
end
