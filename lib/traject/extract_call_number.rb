# frozen_string_literal: true

module ExtractCallNumber
  def extract_call_number
    lambda do |record, accumulator|
      record.fields('HOL852').each do |field|
        call_number = ['h', 'i', 'j'].map { |code| field[code]&.strip }.compact.join(' ')
        accumulator << call_number unless accumulator.include?(call_number)
      end
    end
  end
end
