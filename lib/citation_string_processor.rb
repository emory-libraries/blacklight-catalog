# frozen_string_literal: true

module CitationStringProcessor
  # Chicago Citation
  def chicago_author(obj)
    clean_end_punctuation(obj[:author_tesim]&.join(', '))
  end

  def chicago_publisher(obj)
    publisher = obj[:published_tesim]&.first&.strip
    return nil if publisher.blank?

    publisher = publisher.gsub(/\[|\]/, '')
    clean_end_punctuation(publisher) if publisher.present?
  end

  def chicago_doi(obj)
    doi = obj['other_standard_ids_tesim']&.first&.strip
    clean_end_punctuation(doi) if doi.present?
  end

  # Helper Methods
  def clean_end_punctuation(text)
    [".", ",", ":", ";", "/"].include?(text[-1]) ? text[0...-1] : text
  end
end
