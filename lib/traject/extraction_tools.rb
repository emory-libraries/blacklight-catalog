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
    base_url = field.find { |f| f.code == 'u' }&.value
    return unless base_url
    url = parse_url(base_url)
    link_text = if field['y'].present?
                  field['y']
                elsif field['3'].present?
                  field['3']
                elsif field['z'].present?
                  field['z']
                end
    accumulator << { url: url, description: link_text }.to_json
  end

  def parse_url(base_url)
    parsed_url = URI.parse(base_url)
    return parsed_url if parsed_url.scheme
    parsed_url.to_s.prepend("https://")
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
      extra_fields << [f => value] unless value.empty? # push [key => value] pairs
    end
    # This array contains [key-value] pairs, where the key is the field itself.
    # When working with this returned array in the parent method, be sure to extract values.
    extra_fields
  end

  # method for when you have an subfield order preference for extraction
  # fields must be separated with a space between datafield tag number and list of subfields
  def extract_fields_strict_subfield_order(rec, fields)
    fields = fields.split(':')
    build_arr = []
    fields.each do |f|
      field_num, subfield_tags = f.split(' ')
      rec.fields(field_num).each do |rf|
        inner_build_arr = []
        subfield_tags.split('').each do |t|
          rf.subfields.each { |sf| inner_build_arr << sf.value if sf.code == t }
        end
        build_arr << inner_build_arr.join(' ') if inner_build_arr.present?
      end
    end
    build_arr
  end

  def extract_vern_fields_strict_subfield_order(rec, fields)
    fields = fields.split(':')
    build_arr = []
    fields.each do |f|
      field_num, subfield_tags = f.split(' ')
      rec.fields('880').each do |rf|
        inner_build_arr = []
        if rf.subfields.any? { |sf| sf.code == '6' && sf.value.include?(field_num) }
          subfield_tags.split('').each { |t| rf.subfields.each { |sf| inner_build_arr << sf.value if sf.code == t } }
        end
        build_arr << inner_build_arr.join(' ') if inner_build_arr.present?
      end
    end
    build_arr
  end

  def subject_tesim_str(atoz)
    %W[
      600#{atoz}:610#{atoz}:611#{atoz}:630#{atoz}:650#{atoz}
      651#{atoz}:653#{atoz}:654#{atoz}:655#{atoz}
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
