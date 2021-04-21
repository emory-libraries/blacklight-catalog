# frozen_string_literal: true

module CustomCitationLogic
  # Overrides Blacklight::Solr::Document::MarcExport#apa_citation
  def apa_citation(record)
    solr_doc = SolrDocument.find(record.find { |f| f.tag == '001' }.value)
    build_arr = []

    # Get Author
    get_author_from_solr_apa(solr_doc, build_arr)
    # Get Pub Date
    get_pub_date_from_solr_apa(solr_doc, build_arr)
    # Get title/edition/volume info
    build_title_vol_ed_sections_apa(solr_doc, build_arr)
    # Get Publisher info
    get_publisher_from_solr_apa(solr_doc, build_arr)
    # Get DOI info
    get_doi_from_solr_apa(solr_doc, build_arr)

    build_arr.compact.join(' ')
  end

  def mla_citation(record)
    solr_doc = SolrDocument.find(record.find { |f| f.tag == '001' }.value)
    build_arr = []

    # Get Author
    get_author_from_solr_mla(solr_doc, build_arr)
    # Get title/edition/volume info
    build_title_vol_ed_sections_mla(solr_doc, build_arr)
    # Get Publisher info
    get_publisher_from_solr_apa(solr_doc, build_arr)
    # Get Pub Date
    get_pub_date_from_solr_mla(solr_doc, build_arr)
    # Get Location info
    get_location_from_solr_mla(solr_doc, build_arr)

    build_arr.compact.join(' ')
  end

  def get_author_from_solr_apa(solr_doc, build_arr)
    author = solr_doc['author_ssim']&.first&.strip
    auth_splits = clean_end_punctuation(author).split(', ').flatten if author.present?
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

  def get_title_from_solr_apa(solr_doc)
    build_str = ''
    primary_title = solr_doc['title_tesim']&.first&.strip
    subtitle = solr_doc['subtitle_display_tesim']&.first&.strip

    if primary_title.present? && subtitle.present?
      build_str += "#{clean_end_punctuation(primary_title).strip}:"
      build_str += " #{clean_end_punctuation(subtitle).capitalize}"
    elsif primary_title.present? && subtitle.blank?
      build_str += clean_end_punctuation(primary_title).strip
    end
    build_str
  end

  def get_vol_ed_from_solr_apa(solr_doc)
    vol1 = solr_doc['title_display_partnumber_tesim']&.first&.strip
    vol2 = solr_doc['title_display_partname_tesim']&.first&.strip
    edition = solr_doc['edition_tsim']&.first&.strip
    joined_str = [vol1, vol2, edition].compact.join(', ')
    return "(#{joined_str})" if joined_str.present?
    joined_str
  end

  def get_publisher_from_solr_apa(solr_doc, build_arr)
    publisher = solr_doc['published_ssm']&.first&.strip

    build_arr << "#{clean_end_punctuation(publisher)}." if publisher.present?
  end

  def get_doi_from_solr_apa(solr_doc, build_arr)
    doi = solr_doc['other_standard_ids_ssim']&.first&.strip

    build_arr << "(#{clean_end_punctuation(doi)})" if doi.present?
  end

  def build_title_vol_ed_sections_apa(solr_doc, build_arr)
    title = get_title_from_solr_apa(solr_doc)
    vol_ed = get_vol_ed_from_solr_apa(solr_doc)
    build_arr << if title.present? && vol_ed.present?
                   "<i>" + title + "</i>" + " #{vol_ed}."
                 elsif title.present? && vol_ed.blank?
                   "<i>" + title + "</i>."
                 end
  end

  def get_author_from_solr_mla(solr_doc, build_arr)
    author = solr_doc['author_ssim']&.first&.strip
    author_final = clean_end_punctuation(author)

    build_arr << author_final if author_final.present?
  end

  def get_pub_date_from_solr_mla(solr_doc, build_arr)
    pub_date = solr_doc['pub_date_isim']&.last

    build_arr << "#{pub_date}." if pub_date.present?
  end

  def get_vol_ed_from_solr_mla(solr_doc)
    vol1 = solr_doc['title_display_partnumber_tesim']&.first&.strip
    vol2 = solr_doc['title_display_partname_tesim']&.first&.strip
    edition = solr_doc['edition_tsim']&.first&.strip
    joined_str = [vol1.present? ? "vol. " + vol1.to_s : vol1, vol2.present? ? "vol. " + vol2.to_s : vol2, vol1.present? ? "ed. " + edition : edition].compact.join(', ')
    return joined_str.to_s if joined_str.present?
    joined_str
  end

  def get_location_from_solr_mla(solr_doc, build_arr)
    publisher_location = solr_doc['publisher_location_ssm']&.first&.strip

    build_arr << "#{clean_end_punctuation(publisher_location)}." if publisher_location.present?
  end

  def build_title_vol_ed_sections_mla(solr_doc, build_arr)
    title = get_title_from_solr_apa(solr_doc)
    vol_ed = get_vol_ed_from_solr_mla(solr_doc)
    build_arr << if title.present? && vol_ed.present?
                   "<i>" + title + "</i>" + " #{vol_ed}."
                 elsif title.present? && vol_ed.blank?
                   "<i>" + title + "</i>."
                 end
  end
end
