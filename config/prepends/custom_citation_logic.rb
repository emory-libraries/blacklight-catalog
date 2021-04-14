# frozen_string_literal: true

module CustomCitationLogic
  # Overrides Blacklight::Solr::Document::MarcExport#apa_citation
  def apa_citation(record)
    solr_doc = SolrDocument.find(record.find{|f| f.tag == '001'}.value)
    build_arr = []

    #setup formatted author list
    author = get_author_from_solr_apa(solr_doc)
    build_arr << author if author.present?
    # Get Pub Date
    pub_date = get_pub_date_from_solr_apa(solr_doc)
    build_arr << pub_date if pub_date.present?
    # setup title/edition/volume info
    title = get_title_from_solr_apa(solr_doc)
    build_arr << "<i>" + title + "</i> " if title.present?

    # Edition
    edition_data = setup_edition(record)
    text += edition_data + " " unless edition_data.nil?

    # Publisher info
    text += setup_pub_info(record) unless setup_pub_info(record).nil?
    unless text.blank?
      if text[-1,1] != "."
        text += "."
      end
    end
    text
  end

  def get_author_from_solr_apa(solr_doc)
    author = solr_doc['author_ssim']&.first&.strip
    auth_splits = clean_end_punctuation(author).split(', ').flatten if author.present?

    author = if auth_splits.size == 2
               auth_last, auth_firsts = auth_splits
               auth_inits = auth_firsts.split(' ').map { |s| "#{s.first}." }
               ([auth_last] + auth_inits).join(', ')
             elsif auth_splits.present?
               "#{author}."
             end

    return author if authors.present?
    ''
  end

  def get_pub_date_from_solr_apa(solr_doc)
    pub_date = solr_doc['pub_date_isim']&.last

    return "(#{pub_date})." if pub_date.present?
    ''
  end

  def get_title_from_solr_apa(solr_doc)
    build_str = ''
    primary_title = solr_doc['title_tesim']&.first&.strip
    subtitle = solr_doc['subtitle_display_tesim']&.first&.strip
     =

    if primary_title.present? && subtitle.present?
      build_str += primary_title.last(2) == ' :' ? primary_title : "#{clean_end_punctuation(primary_title)} :"
      build_str += " #{clean_end_punctuation(subtitle).capitalize}."
    elsif primary_title.present? && !subtitle.present?
      build_str += "#{clean_end_punctuation(primary_title)}."
    end
    build_str
  end

  def get_vol_ed_from_solr_apa(solr_doc)
end
