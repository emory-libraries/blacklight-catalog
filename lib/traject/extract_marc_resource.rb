# frozen_string_literal: true

module ExtractMarcResource
  def extract_marc_resource
    lambda do |rec, acc|
      acc << at_library if at_library_rules(rec)
      acc << online if online_rules(rec)
      acc << "Recently Acquired" if recently_acquired(rec)
    end
  end

  def marc_extractor
    Traject::MarcExtractor
  end

  def form_item_data
    marc_extractor.new('008[29]')
  end

  def accomp_data
    marc_extractor.new('008[23]')
  end

  def rec_acq_data
    marc_extractor.new('598a')
  end

  def at_library
    'At the Library'
  end

  def online
    'Online'
  end

  def physical_present(record)
    record.fields('997').present?
  end

  def electronic_present(record)
    record.fields('998').present?
  end

  def leader_formats(record)
    ['e', 'f', 'g', 'k', 'o', 'r'].any? { |l| record.leader[6] == l }
  end

  def form_of_item(record)
    ['o', 's'].any? { |l| form_item_data.extract(record)&.compact&.first == l }
  end

  def accomp_matter(record)
    ['o', 's'].any? { |l| accomp_data.extract(record)&.compact&.first == l }
  end

  def recently_acquired(record)
    rec_acq_data.extract(record)&.compact&.first == 'NEW'
  end

  def neither_present(record)
    !physical_present(record) && !electronic_present(record)
  end

  def at_library_rules(record)
    physical_present(record) || neither_present(record) && (
      leader_formats(record) && !form_of_item(record) ||
        !leader_formats(record) && !accomp_matter(record)
    )
  end

  def online_rules(record)
    electronic_present(record) || neither_present(record) && (
      leader_formats(record) && form_of_item(record) ||
        !leader_formats(record) && accomp_matter(record)
    )
  end
end
