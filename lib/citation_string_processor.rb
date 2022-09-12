# frozen_string_literal: true

module CitationStringProcessor
  def url(obj)
    "https://search.libraries.emory.edu/catalog/#{obj[:id]}" if obj.present? && obj[:id].present?
  end

  def append_string_with_comma(field)
    "#{field&.first}, " if field&.any?(&:present?)
  end

  def append_string_with_period(field)
    "#{field&.first}. " if field&.any?(&:present?)
  end

  def append_string_with_colon(field)
    "#{field&.first}: " if field&.any?(&:present?)
  end

  def author_name_no_period(obj)
    return obj[:author_ssim].map { |a| a.first(a.size - 1) } if obj[:author_ssim]&.any? { |a| a&.split('')&.last == '.' }
    obj[:author_ssim]
  end

  def formatted_chicago_author
    "#{author_name_no_period(obj)&.join(', ')}, " unless author_name_no_period(obj).nil?
  end

  def chicago_default_citation
    "Failed to render citation. Please try again."
  end

  def chicago_publisher(obj)
    publisher = obj[:published_tesim]&.first&.strip
    return nil if publisher.blank?

    publisher = publisher.gsub(/\[|\]/, '')
    [".", ",", ":", ";", "/"].include?(publisher[-1]) ? publisher[0...-1] : publisher
  end
end
