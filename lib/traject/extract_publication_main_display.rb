# frozen_string_literal: true

module ExtractPublicationMainDisplay
  def extract_publication_main_display
    lambda do |rec, acc|
      extra_fields = extract_ordered_fields(rec, '264abc:260abc:245fg:502abcdg')
      unless extra_fields.flatten.empty?
        selected_field = extra_fields.first&.first
        process_field = selected_field["245fg"] # get value of 245 field, because this may contain duplicates and will need processing
        selected_field = if process_field
                           # process 245 field value to remove duplicates
                           process_field.include?(',') ? process_field.partition(', ').first : process_field.partition(' ').first
                         else
                           # if not 245 field, then use the value of key without processing (i.e. 264, 260, 502)
                           selected_field.values.first
                         end
        acc << selected_field
      end
    end
  end
end
