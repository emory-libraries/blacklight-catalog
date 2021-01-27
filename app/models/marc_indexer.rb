# frozen_string_literal: true
$LOAD_PATH.unshift './config'
class MarcIndexer < Blacklight::Marc::Indexer
  # this mixin defines lambda factory method get_format for legacy marc formats
  include Blacklight::Marc::Indexer::Formats

  def initialize
    super

    settings do
      # type may be 'binary', 'xml', or 'json'
      provide "marc_source.type", "binary"
      # set this to be non-negative if threshold should be enforced
      provide 'solr_writer.max_skipped', -1
    end

    to_field "id", extract_marc("001"), trim, first_only
    to_field 'marc_display_tesi', get_xml
    to_field "text_tesi", extract_all_marc_values do |_r, acc|
      acc.replace [acc.join(' ')] # turn it into a single string
    end
    to_field "language_facet_tesim", marc_languages('008[35-37]:041a:041d')
    to_field "format_tesim", get_format
    to_field 'marc_resource_tesim' do |rec, acc|
      acc << "Physical Resource" if rec.fields('997').present?
      acc << "Electronic Resource" if rec.fields('998').present?
    end
    to_field "isbn_ssim", extract_marc('020a', separator: nil) do |_rec, acc|
      orig = acc.dup
      acc.map! { |x| StdNum::ISBN.allNormalizedValues(x) }
      acc << orig
      acc.flatten!
      acc.uniq!
    end
    to_field 'issn_ssim', extract_marc('022a')
    to_field 'lccn_ssim', extract_marc('010a')
    to_field 'oclc_ssim', oclcnum('019a:035a')
    to_field 'other_standard_ids_ssim', extract_marc('024a')
    to_field 'publisher_number_ssim', extract_marc('028a')
    to_field 'material_type_display_tesim', extract_marc('300a'), trim_punctuation

    # Title fields
    #    primary title
    to_field 'title_tesim', extract_marc('245a')
    to_field 'title_display_tesim', extract_marc('245a', alternate_script: false), trim_punctuation
    to_field 'title_vern_display_tesi', extract_marc('245a', alternate_script: :only), trim_punctuation

    #    subtitle
    to_field 'subtitle_t', extract_marc('245b')
    to_field 'subtitle_display_tesim', extract_marc('245b', alternate_script: false), trim_punctuation
    to_field 'subtitle_vern_display_tesi', extract_marc('245b', alternate_script: :only), trim_punctuation

    #    additional title fields
    to_field 'title_abbr_tesi', extract_marc('210ab')
    to_field 'title_addl_tesim', extract_marc(%w[
      130abcdefghijklmnopqrstuvwxyz
      240abcdefgklmnopqrs
      243abcdefgklmnopqrs
    ].join(':'))
    to_field 'title_added_entry_tesim', extract_marc(%w[
      700gklmnoprst
      710fgklmnopqrst
      711fgklnpst
      730abcdefgklmnopqrst
      740anp
    ].join(':'))
    to_field 'title_enhanced_tesim', extract_marc(
      "505abcdefghijklmnopqrsuvwxyz"
    )

    to_field 'title_si', marc_sortable_title

    # Author fields

    to_field 'author_tsim', extract_marc("100abcegqu:110abcdegnu:111acdegjnqu")
    to_field 'author_addl_tsim', extract_marc("700abcegqu:710abcdegnu:711acdegjnqu")
    to_field 'author_ssm', extract_marc("100abcdq:110#{ATOZ}:111#{ATOZ}", alternate_script: false)
    to_field 'author_vern_ssm', extract_marc("100abcdq:110#{ATOZ}:111#{ATOZ}", alternate_script: :only)

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
  end
end
