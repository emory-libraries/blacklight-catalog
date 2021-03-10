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
    field.find_all { |sf| sf.code == 'u' }.each { |url| accumulator << url.value }
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

  def subject_tsim_str(atou)
    %W[
      600#{atou}
      610#{atou}
      611#{atou}
      630#{atou}
      650abcde
      651ae:653a
      654abcde
      655abc
    ].join(':').freeze
  end

  def title_series_ssim_str(atoz)
    %W[
      440anpv:490av
      800#{atoz}
      810#{atoz}
      811#{atoz}
      830#{atoz}
      840#{atoz}
    ].join(':').freeze
  end

  def title_added_entry_tesim_str
    %w[
      700gklmnoprst
      710fgklmnopqrst
      711fgklnpst
      730abcdefgklmnopqrst
      740anp
    ].join(':').freeze
  end

  def title_addl_tesim_str(atoz, atog, ktos)
    %W[
      130#{atoz}
      210ab:222ab
      240#{atog}#{ktos}
      242abnp
      243#{atog}#{ktos}
      245abnps
      246#{atog}np
      247#{atog}np
    ].join(':').freeze
  end

  def format_map_ldr_six
    {
      'c' => "Musical Score", 'd' => "Musical Score", 'e' => "Map", 'f' => "Map",
      'g' => "Visual Material", 'i' => "Sound Recording", 'j' => "Sound Recording",
      'k' => "Visual Material", 'm' => "Computer File", 'o' => "Visual Material",
      'p' => "Mixed Materials", 'r' => "Visual Material"
    }.freeze
  end

  def format_map_ldr_six_seven
    {
      'aa' => "Book", 'ab' => "Serial", 'ac' => "Book", 'ad' => "Book", 'ai' => "Serial",
      'am' => "Book", 'as' => "Serial", 'ta' => "Book", 'tb' => "Serial", 'tc' => "Book",
      'td' => "Book", 'ti' => "Serial", 'tm' => "Book", 'ts' => "Serial"
    }.freeze
  end
end
