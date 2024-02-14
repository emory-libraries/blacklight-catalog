# frozen_string_literal: true

require 'openurl'
require './lib/chicago_citation_formatter'

# blacklight-marc v7.2.0 overwrite
# Overwrites the apa_citation and mla_citation methods from module of same name
# as well as adds new methods to assist the new logic.
module Blacklight::Marc::DocumentExport
  def self.register_export_formats(document)
    document.will_export_as(:xml)
    document.will_export_as(:marc, "application/marc")
    # marcxml content type:
    # http://tools.ietf.org/html/draft-denenberg-mods-etc-media-types-00
    document.will_export_as(:marcxml, "application/marcxml+xml")
    document.will_export_as(:openurl_ctx_kev, "application/x-openurl-ctx-kev")
    document.will_export_as(:refworks_marc_txt, "text/plain")
    document.will_export_as(:endnote, "application/x-endnote-refer")
    document.will_export_as(:ris, "application/ris")
  end

  def export_as_marc
    to_marc.to_marc
  end

  def export_as_marcxml
    to_marc.to_xml.to_s
  end

  alias export_as_xml export_as_marcxml

  # TODO: This exporting as formatted citation thing should be re-thought
  # redesigned at some point to be more general purpose, but this
  # is in-line with what we had before, but at least now attached
  # to the document extension where it belongs.
  def export_as_apa_citation_txt
    apa_citation(to_marc)
  end

  def export_as_mla_citation_txt
    mla_citation(to_marc)
  end

  def export_as_chicago_citation_txt
    ChicagoCitationFormatter.new(self).cite!
  rescue
    chicago_citation(to_marc)
  end

  # Exports as an OpenURL KEV (key-encoded value) query string.
  # For use to create COinS, among other things. COinS are
  # for Zotero, among other things.

  def export_as_openurl_ctx_kev(format = nil)
    format = self[:format_ssim]
    format = format.is_a?(Array) ? format[0].downcase.strip : format.downcase.strip if format.present?

    context_object = OpenURL::ContextObject.new

    if format == 'book'
      context_object.referent.set_format('book')
      metadata = {
        'genre' => 'book',
        'title' => self[:title_citation_ssi],
        'btitle' => self[:title_citation_ssi],
        'au' => self[:author_ssim],
        'date' => self[:pub_date_isim],
        'place' => self[:publisher_location_ssim],
        'pub' => self[:published_tesim]&.first&.gsub(/\[|\]/, ''),
        'edition' => self[:edition_tsim],
        'isbn' => self[:isbn_ssim]
      }
    else
      context_object.referent.set_format('dc')
      metadata = {
        'genre' => 'dc',
        'title' => self[:title_citation_ssi],
        'creator' => self[:author_ssim],
        'date' => self[:pub_date_isim],
        'place' => self[:publisher_location_ssim],
        'pub' => self[:published_tesim]&.first&.gsub(/\[|\]/, '')
      }
    end

    metadata.each do |key, value|
      data = value.is_a?(Array) ? value&.first.to_s : value.to_s
      context_object.referent.set_metadata(key, data.strip)
    end

    context_object.kev
  end

  # This format used to be called 'refworks', which wasn't really
  # accurate, sounds more like 'refworks tagged format'. Which this
  # is not, it's instead some weird under-documented Refworks
  # proprietary marc-ish in text/plain format. See
  # http://robotlibrarian.billdueber.com/2009/05/sending-marcish-data-to-refworks/
  def export_as_refworks_marc_txt
    marc_obj = to_marc
    return unless marc_obj
    fields = marc_obj.find_all { |f| ('000'..'999') == f.tag }
    text = "LEADER #{to_marc.leader}"
    fields.each do |field|
      unless ["940", "999"].include?(field.tag)
        if field.is_a?(MARC::ControlField)
          text += "#{field.tag}    #{field.value}\n"
        else
          text += "#{field.tag} "
          text += (field.indicator1 ? field.indicator1 : " ")
          text += (field.indicator2 ? field.indicator2 : " ")
          text += " "
          field.each { |s| text += s.code == 'a' ? s.value.to_s : " |#{s.code}#{s.value}" }
          text += "\n"
        end
      end
    end

    # As of 11 May 2010, Refworks has a problem with UTF-8 if it's decomposed,
    # it seems to want C form normalization, although RefWorks support
    # couldn't tell me that. -jrochkind
    text = ActiveSupport::Multibyte::Unicode.normalize(text, :c)
    text
  end

  # Very preliminary implementation of RIS format. Only gives first value of multi-value Solr fields
  def export_as_ris
    ris_format = {
      "A2" => :author_addl_ssim,
      "AU" => :author_tesim,
      "CN" => :local_call_number_tesim,
      "CY" => :publisher_location_ssim,
      "DO" => :other_standard_ids_tesim,
      "ET" => :edition_tsim,
      "L2" => :url_fulltext_ssm,
      "LA" => :language_tesim,
      "PB" => :published_tesim,
      "PP" => :publisher_location_ssim,
      "PY" => :pub_date_isim,
      "SN" => :isbn_ssim,
      "TI" => :title_citation_ssi,
      "TT" => :title_translation_tesim,
      "VO" => :other_standard_ids_tesim,
      "ER" => ""
    }
    ris_format.each do |ris_key, solr_field|
      ris_format[ris_key] = [*try(:[], solr_field)]
    end
    # TODO: crosswalk formats with allowed Type values for RIS
    text = "TY  - GEN\n"
    ris_format.each do |ris_key, value|
      if ris_key == "DO"
        dois = value.select { |v| v.include? "doi:" }
        dois.each { |d| text += "DO  - #{d.split(': ').last}\n" } if dois.present?
      elsif ris_key == "VO"
        psn = value.select { |v| !v.include? "doi:" }
        psn.each { |p| text += "VO  - #{p}\n" } if psn.present?
      elsif ris_key == "ER"
        text += "#{ris_key}  - \n"
      elsif ris_key == "L2" && value.present?
        value.each { |v| text += "#{ris_key}  - #{JSON.parse(v)['url']}\n" }
      elsif value.present?
        value.each { |v| text += "#{ris_key}  - #{v}\n" }
      end
    end
    text
  end

  # Endnote Import Format. See the EndNote User Guide at:
  # http://www.endnote.com/support/enx3man-terms-win.asp
  # Chapter 7: Importing Reference Data into EndNote / Creating a Tagged “EndNote Import” File
  #
  # Note: This code is copied from what used to be in the previous version
  # in ApplicationHelper#render_to_endnote.  It does NOT produce very good
  # endnote import format; the %0 is likely to be entirely illegal, the
  # rest of the data is barely correct but messy. TODO, a new version of this,
  # or better yet just an export_as_ris instead, which will be more general
  # purpose.
  def export_as_endnote
    end_note_format = {
      "%A" => "100.a",
      "%C" => "260.a",
      "%D" => "260.c",
      "%E" => "700.a",
      "%I" => "260.b",
      "%J" => "440.a",
      "%@" => "020.a",
      "%_@" => "022.a",
      "%T" => "245.a,245.b",
      "%U" => "856.u",
      "%7" => "250.a"
    }
    marc_obj = to_marc
    return unless marc_obj

    # TODO. This should be rewritten to guess
    # from actual Marc instead, probably.
    format_str = 'Generic'

    text = ''
    text += "%0 #{format_str}\n"
    # If there is some reliable way of getting the language of a record we can add it here
    # text << "%G #{record['language'].first}\n"
    end_note_format.each do |key, value|
      values = value.split(",")
      first_value = values[0].split('.')
      second_value = if values.length > 1
                       values[1].split('.')
                     else
                       []
                     end

      next unless marc_obj[first_value[0].to_s]
      marc_obj.find_all { |f| first_value[0].to_s == f.tag }.each do |field|
        next unless field[first_value[1]].to_s || field[second_value[1]].to_s
        text += key.delete('_').to_s
        text += " #{field[first_value[1]]}" if field[first_value[1]].to_s
        text += " #{field[second_value[1]]}" if field[second_value[1]].to_s
        text += "\n"
      end
    end
    text
  end

  protected

  # Main method for defining chicago style citation.  If we don't end up converting to using a citation formatting service
  # we should make this receive a semantic document and not MARC so we can use this with other formats.
  # rubocop:disable Metrics/BlockNesting
  def chicago_citation(marc)
    authors = get_all_authors(marc)
    author_text = ""
    if authors[:primary_authors].present?
      if authors[:primary_authors].length > 10
        authors[:primary_authors].each_with_index do |author, index|
          if index < 7
            if index.zero?
              author_text += author.to_s
              author_text += if author.ends_with?(",")
                               " "
                             else
                               ", "
                             end
            else
              author_text += "#{name_reverse(author)}, "
            end
          end
        end
        author_text += " et al."
      elsif authors[:primary_authors].length > 1
        authors[:primary_authors].each_with_index do |author, index|
          if index.zero?
            author_text += author.to_s
            author_text += if author.ends_with?(",")
                             " "
                           else
                             ", "
                           end
          elsif index + 1 == authors[:primary_authors].length
            author_text += "and #{name_reverse(author)}."
          else
            author_text += "#{name_reverse(author)}, "
          end
        end
      else
        author_text += authors[:primary_authors].first
      end
    else
      temp_authors = []
      authors[:translators].each do |translator|
        temp_authors << [translator, "trans."]
      end
      authors[:editors].each do |editor|
        temp_authors << [editor, "ed."]
      end
      authors[:compilers].each do |compiler|
        temp_authors << [compiler, "comp."]
      end

      if temp_authors.present?
        if temp_authors.length > 10
          temp_authors.each_with_index do |author, index|
            author_text += "#{author.first} #{author.last} " if index < 7
          end
          author_text += " et al."
        elsif temp_authors.length > 1
          temp_authors.each_with_index do |author, index|
            author_text += if index.zero?
                             "#{author.first} #{author.last}, "
                           elsif index + 1 == temp_authors.length
                             "and #{name_reverse(author.first)} #{author.last}"
                           else
                             "#{name_reverse(author.first)} #{author.last}, "
                           end
          end
        else
          author_text += "#{temp_authors.first.first} #{temp_authors.first.last}"
        end
      end
    end
    title = ""
    additional_title = ""
    section_title = ""
    if marc["245"] && (marc["245"]["a"] || marc["245"]["b"])
      title += citation_title(clean_end_punctuation(marc["245"]["a"]).strip) if marc["245"]["a"]
      title += ": #{citation_title(clean_end_punctuation(marc['245']['b']).strip)}" if marc["245"]["b"]
    end
    if marc["245"] && (marc["245"]["n"] || marc["245"]["p"])
      section_title += citation_title(clean_end_punctuation(marc["245"]["n"])) if marc["245"]["n"]
      if marc["245"]["p"]
        section_title += ", <i>#{citation_title(clean_end_punctuation(marc['245']['p']))}.</i>"
      elsif marc["245"]["n"]
        section_title += "."
      end
    end

    if authors[:primary_authors].present? && (authors[:translators].present? || authors[:editors].present? || authors[:compilers].present?)
      additional_title += "Translated by #{authors[:translators].collect { |name| name_reverse(name) }.join(' and ')}. " if authors[:translators].present?
      additional_title += "Edited by #{authors[:editors].collect { |name| name_reverse(name) }.join(' and ')}. " if authors[:editors].present?
      additional_title += "Compiled by #{authors[:compilers].collect { |name| name_reverse(name) }.join(' and ')}. " if authors[:compilers].present?
    end

    edition = ""
    edition += setup_edition(marc) unless setup_edition(marc).nil?

    pub_info = ""
    if marc["260"] && (marc["260"]["a"] || marc["260"]["b"])
      pub_info += clean_end_punctuation(marc["260"]["a"]).strip if marc["260"]["a"]
      pub_info += ": #{clean_end_punctuation(marc['260']['b']).strip}" if marc["260"]["b"]
      pub_info += ", #{setup_pub_date(marc)}" if marc["260"]["c"]
    elsif marc["502"] && marc["502"]["a"] # MARC 502 is the Dissertation Note.  This holds the correct pub info for these types of records.
      pub_info += marc["502"]["a"]
    elsif marc["502"] && (marc["502"]["b"] || marc["502"]["c"] || marc["502"]["d"]) # sometimes the dissertation note is encoded in pieces in the $b $c and $d sub fields instead of lumped into the $a
      pub_info += "#{marc['502']['b']}, #{marc['502']['c']}, #{clean_end_punctuation(marc['502']['d'])}"
    end

    citation = ""
    citation += "#{author_text} " if author_text.present?
    citation += "<i>#{title}.</i> " if title.present?
    citation += "#{section_title} " if section_title.present?
    citation += "#{additional_title} " if additional_title.present?
    citation += "#{edition} " if edition.present?
    citation += "#{pub_info}." if pub_info.present?
    citation
  end
  # rubocop:enable Metrics/BlockNesting

  def mla_citation(record)
    solr_doc = SolrDocument.find(record.find { |f| f.tag == '001' }.value)
    build_arr = []

    # Get Author
    get_author_from_solr_mla(record, build_arr) if record['100'].present?
    # Get title/edition/volume info
    build_title_mla(solr_doc, build_arr)
    # Get Publisher doi info
    get_publisher_doi_from_solr_mla(solr_doc, build_arr)

    build_arr.compact.join(' ')
  end

  def apa_citation(record)
    solr_doc = SolrDocument.find(record.find { |f| f.tag == '001' }.value)
    build_arr = []

    if record['100'].present?
      # Get Author
      get_author_from_solr_apa(solr_doc, build_arr)
      # Get Pub Date
      get_pub_date_from_solr_apa(solr_doc, build_arr)
      # Get title/edition/volume info
      build_title_apa(solr_doc, build_arr)
    else
      # Get title/edition/volume info
      build_title_apa(solr_doc, build_arr)
      # Get Pub Date
      get_pub_date_from_solr_apa(solr_doc, build_arr)
    end
    # Get Publisher info
    get_publisher_from_solr_apa(solr_doc, build_arr)
    # Get DOI info
    get_doi_from_solr_apa(solr_doc, build_arr)

    build_arr.compact.join(' ')
  end

  def get_author_from_solr_apa(solr_doc, build_arr)
    author = solr_doc['author_ssim']&.first&.strip
    auth_splits = clean_end_punctuation(remove_parentheses(author)).split(', ').flatten if author.present?
    author = format_author_string(author, auth_splits)

    build_arr << author if author.present?
  end

  def format_author_string(author, auth_splits)
    if auth_splits.present? && auth_splits.size >= 2
      auth_last = auth_splits[0]
      auth_firsts = auth_splits - [auth_last]
      auth_firsts.each { |f| auth_firsts.delete(f) unless f.first.match?(/[[:alpha:]]/) }
      auth_inits = auth_firsts&.map { |s| s.split(' ').map { |ss| "#{ss.first}." } }&.flatten&.join(' ')
      [auth_last, auth_inits].join(', ')
    elsif auth_splits.present?
      "#{author}."
    end
  end

  def get_pub_date_from_solr_apa(solr_doc, build_arr)
    pub_date = solr_doc['pub_date_isim']&.last

    build_arr << "(#{pub_date})." if pub_date.present?
  end

  def get_publisher_from_solr_apa(solr_doc, build_arr)
    publisher = solr_doc['published_tesim']&.first&.strip
    build_arr << "#{clean_end_punctuation(remove_sq_brackets(publisher))}." if publisher.present?
  end

  def get_doi_from_solr_apa(solr_doc, build_arr)
    doi = solr_doc['other_standard_ids_tesim']&.first&.strip
    build_arr << clean_end_punctuation(doi) if doi.present?
  end

  def build_title_mla(solr_doc, build_arr)
    title = solr_doc['title_citation_ssi'].present? ? citation_title(replace_whitespace_colon(solr_doc['title_citation_ssi'])) : ''
    build_arr << "<i>#{title}</i>." if title.present?
  end

  def build_title_apa(solr_doc, build_arr)
    title = solr_doc['title_citation_ssi'].present? ? capitalize_apa(replace_whitespace_colon(solr_doc['title_citation_ssi'])) : ''
    build_arr << "<i>#{title}</i>." if title.present?
  end

  def get_author_from_solr_mla(record, build_arr)
    author = record['100']['a']
    author_final = author.present? ? "#{clean_end_punctuation(author)}." : ''
    build_arr << author_final if author_final.present?
  end

  def get_publisher_doi_from_solr_mla(solr_doc, build_arr)
    pub_info = ""
    publisher = solr_doc['published_tesim']&.first&.strip
    pub_date = solr_doc['pub_date_isim']&.last
    publisher_location = solr_doc['publisher_location_ssm']&.first&.strip
    doi = solr_doc['other_standard_ids_tesim']&.first&.strip
    pub_info += clean_end_punctuation(remove_sq_brackets(publisher)) if publisher.present?
    pub_info += ", #{pub_date}" if pub_date.present?
    pub_info += ", #{clean_end_punctuation(publisher_location)}" if publisher_location.present?
    pub_info += ", #{clean_end_punctuation(doi)}" if doi.present?
    pub_info += "."
    build_arr << pub_info
  end

  def setup_pub_date(record)
    if record.find { |f| f.tag == '260' }.present?
      pub_date = record.find { |f| f.tag == '260' }
      if pub_date.find { |s| s.code == 'c' }
        date_value = pub_date.find { |s| s.code == 'c' }.value.gsub(/[^0-9|n\.d\.]/, "")[0, 4] if pub_date.find { |s| s.code == 'c' }.value.gsub(/[^0-9|n\.d\.]/, "")[0, 4].present?
      end
      return nil if date_value.nil?
    end
    clean_end_punctuation(date_value) if date_value
  end

  # This will replace the mla_citation_title method with a better understanding of how MLA and Chicago citation titles are formatted.
  # This method will take in a string and capitalize all of the non-prepositions.
  def citation_title(title_text)
    prepositions = ["a", "about", "across", "an", "and", "before", "but", "by", "for", "it", "of", "the", "to", "with", "without", "through"]
    new_text = []
    title_text.split(" ").each_with_index do |word, index|
      new_text << if (index.zero? && word != word.upcase) || (word.length > 1 && word != word.upcase && !prepositions.include?(word))
                    # the split("-") will handle the capitalization of hyphenated words
                    word.split("-").map!(&:capitalize).join("-")
                  else
                    word
                  end
    end
    new_text.join(" ")
  end

  def clean_end_punctuation(text)
    return text[0, text.length - 1] if [".", ",", ":", ";", "/"].include? text[-1, 1]
    text
  end

  def setup_edition(record)
    edition_field = record.find { |f| f.tag == '250' }
    edition_code = edition_field.find { |s| s.code == 'a' } unless edition_field.nil?
    edition_data = edition_code.value unless edition_code.nil?

    return nil if edition_data.nil? || edition_data == '1st ed.'
    edition_data
  end

  # This is a replacement method for the get_author_list method.  This new method will break authors out into primary authors, translators, editors, and compilers
  def get_all_authors(record)
    translator_code = "trl"
    editor_code = "edt"
    compiler_code = "com"
    primary_authors = []
    translators = []
    editors = []
    compilers = []

    record.find_all { |f| f.tag == "100" }.each do |field|
      primary_authors << field["a"] if field["a"]
    end
    record.find_all { |f| f.tag == "700" }.each do |field|
      next unless field["a"]
      relators = []
      relators << clean_end_punctuation(field["e"]) if field["e"]
      relators << clean_end_punctuation(field["4"]) if field["4"]
      if relators.include?(translator_code)
        translators << field["a"]
      elsif relators.include?(editor_code)
        editors << field["a"]
      elsif relators.include?(compiler_code)
        compilers << field["a"]
      else
        primary_authors << field["a"]
      end
    end
    { primary_authors:, translators:, editors:, compilers: }
  end

  def name_reverse(name)
    name = clean_end_punctuation(name)
    return name unless name.match?(/,/)
    temp_name = name.split(", ")
    temp_name.last + " " + temp_name.first
  end

  def remove_parentheses(str)
    str.gsub(/\(.*?\)/, '')
  end

  def remove_sq_brackets(str)
    str.gsub(/\[|\]/, '')
  end

  def replace_whitespace_colon(str)
    str.gsub(/\s:/, ':')
  end

  def capitalize_apa(str)
    cap_colon = str.gsub(/: [a-z]/, &:upcase)
    cap_colon.gsub(/- [a-z]/, &:upcase)
  end
end
