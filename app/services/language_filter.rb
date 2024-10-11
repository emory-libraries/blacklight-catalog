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
    @term_regexes = @terms.map { |term| [Regexp.new(Regexp.escape(term), Regexp::IGNORECASE), @filter_data[term]['replacement']] }.to_h
  end

  # Checks if the input is valid, i.e., doesn't need replacement.
  #
  # @param input [String] The input text to check.
  # @return [Boolean] Returns true if the input is valid, false if it needs replacement.
  def valid?(input)
    return true if input.blank?

    @term_regexes.keys.none? { |regex| input.match?(regex) }
  end

  # Gets the filtered version of the input text.
  #
  # @param input [String] The input text to filter and replace.
  # @return [String] The filtered version of the input text.
  def filter(input)
    return nil if input.blank?

    output = input.dup

    @term_regexes.each do |regex, replacement|
      output.gsub!(regex, replacement)
    end

    output
  end
end
