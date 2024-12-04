# frozen_string_literal: true

module ExtractPublicationDate
  def extract_publication_date
    lambda do |rec, acc|
      if rec['008']
        date_type = rec['008'].value[0o6]
        start_year = rec['008'].value[0o7, 4]
        end_year = rec['008'].value[11, 4] == '9999' ? Date.current.year.to_s : rec['008'].value[11, 4]
        if range_processing?(date_type, start_year, end_year)
          possible_range_processing(start_year, end_year, rec, acc)
        elsif include_zeroes?(start_year, end_year) && not_include_alpha_characters?(start_year, end_year)
          zeroes_processing(date_type, start_year, rec, acc)
        else
          pub_date_from_traject(rec, acc)
        end
      end
    end
  end

  def years_to_array(start_year, end_year)
    (start_year..end_year).to_a
  end

  def pub_date_from_traject(rec, acc)
    date = Traject::Macros::Marc21Semantics.publication_date(rec)
    acc << date if date
  end

  def possible_range_processing(start_year, end_year, rec, acc)
    if start_year.present? && end_year.present?
      ret_array = years_to_array(start_year, end_year)
      ret_array.each { |r| acc << r }
    else
      # it could happen that sometimes the start or end year is missing then fallback on traject's pub date method
      pub_date_from_traject(rec, acc)
    end
  end

  def zeroes_processing(date_type, start_year, rec, acc)
    acc << start_year if date_type == 's' && /(\d{4})/.match?(start_year) && start_year != '0000'
    return if start_year == '0000' && date_type == 'c' || date_type == 'n'
    pub_date_from_traject(rec, acc) if acc.blank?
  end

  def include_zeroes?(start_year, end_year)
    [start_year, end_year].include?('0000')
  end

  def not_include_alpha_characters?(start_year, end_year)
    ![start_year, end_year].any? { |y| /\D/.match?(y) }
  end

  def range_processing?(date_type, start_year, end_year)
    ['i', 'k', 'c'].include?(date_type) && !include_zeroes?(start_year, end_year) &&
      not_include_alpha_characters?(start_year, end_year)
  end
end
