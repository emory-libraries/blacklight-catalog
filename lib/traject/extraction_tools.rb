# frozen_string_literal: true

module ExtractionTools
  def marc21
    Traject::Macros::Marc21
  end

  def extract_join_remove(record, field_num_tag)
    marc21.extract_marc_from(record, field_num_tag).join(' ').remove(" :", "[", "]")
  end

  def fill_str_arr_prefix(string_array, prefix)
    string_array << prefix.flatten.join(' ') unless prefix.all?("")
  end

  def fill_str_arr_suffix(string_array, suffix)
    string_array << ": " + suffix.flatten.join(' ') unless suffix.all?("")
  end

  def accumulate_urls(field, accumulator)
    url = field.find { |f| f.code == 'u' }&.value
    link_text = if field['y'].present?
                  field['y']
                elsif field['3'].present?
                  field['3']
                elsif field['z'].present?
                  field['z']
                end
    accumulator << { url.to_s => link_text }.to_json
  end

  def fields_z3(field)
    [field['z'], field['3']].join(' ')
  end

  def accumulate_field_u(field, accumulator)
    accumulator << field['u'] unless field['u'].nil?
  end

  def notfulltext
    /abstract|description|sample text|table of contents|/i
  end

  def alpha_pat
    /\A([A-Z]{1,3})\d.*\Z/
  end

  def alpha_only
    lambda do |_rec, acc|
      acc.map! { |x| (m = alpha_pat.match(x)) ? m[1] : nil }
      acc.compact! # eliminate nils
    end
  end

  def first_letter
    ->(_rec, acc) { acc.map! { |x| x[0] } }
  end

  def trim
    ->(_record, accumulator) { accumulator.each(&:strip!) }
  end

  def get_xml(_options = {})
    ->(record, accumulator) { accumulator << MARC::FastXMLWriter.encode(record) }
  end

  def corp_name_datafields(record)
    record.fields('710').select do |f|
      f.indicator1 == '2' && f.subfields.any? { |s| s.value == 'GEU' && s.code == '5' }
    end
  end

  def c_n_subfield_values(datafields)
    datafields&.map { |df| df.subfields.map { |sf| sf.value if sf.code == 'a' } }&.compact&.flatten
  end

  # method for when you have an order preference for extraction
  def extract_ordered_fields(rec, fields)
    fields = fields.split(':')
    extra_fields = []
    fields.each do |f|
      value = marc21.extract_marc_from(rec, f, trim_punctuation: true)
      extra_fields << [f => value.first] unless value.empty? # push [key => value] pairs
    end
    # This array contains [key-value] pairs, where the key is the field itself.
    # When working with this returned array in the parent method, be sure to extract values.
    extra_fields
  end

  def subject_tsim_str(atou)
    %W[
      600#{atou}
      610#{atou}
      611#{atou}
      630#{atou}
      650abcde:651ae:653a:654abcde:655abc
    ].join(':').freeze
  end

  def title_series_str(atog)
    %W[
      440anpv:490av
      830#{atog}kv
      800#{atog}jklmnopqrstv
      810#{atog}klmnoprstv
      811acdefgjklnopqstv
    ].join(':').freeze
  end

  def title_added_entry_tesim_str
    %w[
      700gklmnoprst:710fgklmnopqrst
      711fgklnpst
      730abcdefgklmnopqrst:740az:700f:505t
    ].join(':').freeze
  end

  def format_map_ldr_six
    {
      'c' => "Musical Score", 'd' => "Musical Score", 'e' => "Map", 'f' => "Map",
      'g' => "Video/Visual Material", 'i' => "Sound Recording", 'j' => "Sound Recording",
      'k' => "Video/Visual Material", 'm' => "Computer File", 'o' => "Video/Visual Material",
      'p' => "Archival Material/Manuscripts", 'r' => "Video/Visual Material"
    }.freeze
  end

  def format_map_ldr_six_seven
    {
      'aa' => "Book", 'ab' => "Journal, Newspaper or Serial", 'ac' => "Book", 'ad' => "Book",
      'ai' => "Journal, Newspaper or Serial", 'am' => "Book", 'as' => "Journal, Newspaper or Serial",
      'ta' => "Book", 'tb' => "Journal, Newspaper or Serial", 'tc' => "Book", 'td' => "Book",
      'ti' => "Journal, Newspaper or Serial", 'tm' => "Book", 'ts' => "Journal, Newspaper or Serial"
    }.freeze
  end
end
