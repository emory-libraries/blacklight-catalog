# frozen_string_literal: true

module ExtractPublished
  def extract_published
    lambda do |rec, acc|
      extra_fields = extract_ordered_fields(rec, '264b:260b:502c').flatten
      acc << extra_fields.first.values.first if extra_fields.present?
    end
  end
end
