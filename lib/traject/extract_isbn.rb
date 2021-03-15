# frozen_string_literal: true

module ExtractIsbn
  def extract_isbn
    extract_marc('020a', separator: nil) do |_rec, acc|
      orig = acc.dup
      acc.map! { |x| StdNum::ISBN.allNormalizedValues(x) }
      acc << orig
      acc.flatten!
      acc.uniq!
    end
  end
end
