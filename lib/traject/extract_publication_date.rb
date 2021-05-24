# frozen_string_literal: true

module ExtractPublicationDate
  def extract_publication_date
    lambda do |rec, acc|
      if rec['008']
        case rec['008'].value[0o6]
        when 'i', 'k', 'c'
          possible_range_processing(start_year(rec), end_year(rec), rec, acc)
        else
          # use traject's pub date method if 008[6] is not i, k, or c
          # until we flesh this method out to include all possible date/year scenarios.
          pub_date_from_traject(rec, acc)
        end
      end
    end
  end

  def start_year(rec)
    year = rec['008'].value[0o7, 4]
    # return year unless it includes anything from the garbage list above. We will write a solution for this later.
    year unless contains_garbage?(year)
  end

  def end_year(rec)
    year = rec['008'].value[11, 4]
    if year == '9999'
      Date.current.year.to_s
    else
      # return year unless it includes anything from the garbage list above. We will write a solution for this later.
      year unless contains_garbage?(year)
    end
  end

  def years_to_array(start_year, end_year)
    (start_year..end_year).to_a
  end

  def pub_date_from_traject(rec, acc)
    date = Traject::Macros::Marc21Semantics.publication_date(rec)
    acc << date if date
  end

  def contains_garbage?(year)
    year.match?(/\D/)
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
end
