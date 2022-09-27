# frozen_string_literal: true

module CitationStringProcessor
  # Chicago Citation
  def chicago_author(obj)
    author = obj.to_marc['100'] ? obj.to_marc['100']['a'] : nil
    author.present? ? clean_end_punctuation(author) : nil
  end

  def chicago_publisher(obj)
    publisher = obj[:published_tesim]&.first&.strip
    return nil if publisher.blank?

    publisher = publisher.gsub(/\[|\]/, '')
    publisher.present? ? clean_end_punctuation(publisher) : nil
  end

  def chicago_doi(obj)
    standard_ids = obj['other_standard_ids_tesim']
    doi = standard_ids&.find { |v| v.match?(/doi:/) }
    doi.present? ? clean_end_punctuation(doi).partition('doi: ').last : nil
  end

  # Helper Methods
  def clean_end_punctuation(text)
    [".", ",", ":", ";", "/"].include?(text[-1]) ? text[0...-1] : text
  end
end
