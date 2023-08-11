# frozen_string_literal: true

require 'yaml'

# A class for filtering text based on a predefined filter.
class LanguageFilter
  # Initializes a new LanguageFilter instance.
  #
  # @param filter_file_path [Pathname] The path to the YAML file containing filter data.
  def initialize(filter_file_path = Rails.root.join('config', 'language_filter.yml'))
    @filter_data = YAML.load_file(filter_file_path)
    @terms = @filter_data.keys.sort { |a, b| b.length <=> a.length }
  end

  # Checks if the input is valid, i.e., doesn't need replacement.
  #
  # @param input [String] The input text to check.
  # @return [Boolean] Returns true if the input is valid, false if it needs replacement.
  def valid?(input)
    return true if input.blank?

    @terms.each do |term|
      return false if input.include?(term)
    end

    true
  end

  # Gets the filtered version of the input text.
  #
  # @param input [String] The input text to filter and replace.
  # @return [String] The filtered version of the input text.
  def filter(input)
    return nil if input.blank?

    output = input.dup

    @terms.each do |term|
      output.gsub!(term, @filter_data[term]['replacement']) if output.include?(term)
    end

    output
  end
end
