# frozen_string_literal: true
require 'rails_helper'

RSpec.describe LanguageFilter do
  let(:filter_data) do
    {
      "Gender identity disorder" => {
        "replacement" => "Gender dysphoria"
      },
      "Gender identity disorders" => {
        "replacement" => "Gender dysphoria"
      }
    }
  end

  before do
    allow(YAML).to receive(:load_file).and_return(filter_data)
  end

  describe '#valid?' do
    let(:filter) { described_class.new }

    it 'returns true when input is valid' do
      input = "Georgia"

      expect(filter.valid?(input)).to eq(true)
    end

    it 'returns false when input is invalid' do
      input = "Gender identity disorder"

      expect(filter.valid?(input)).to eq(false)
    end

    it 'returns true when input is nil' do
      input = nil

      expect(filter.valid?(input)).to eq(true)
    end
  end

  describe '#filter' do
    let(:filter) { described_class.new }

    it 'returns original value when input is valid' do
      input = 'Georgia'
      expected = 'Georgia'

      expect(filter.filter(input)).to eq(expected)
    end

    it 'replaces harmful text with corresponding replacements' do
      input = 'Gender identity disorder'
      expected = 'Gender dysphoria'

      expect(filter.filter(input)).to eq(expected)
    end

    it 'prioritizes terms with higher length during replacement' do
      input = 'Gender identity disorders'
      expected = 'Gender dysphoria'

      expect(filter.filter(input)).to eq(expected)
    end

    it 'only replaces harmful terms when multiple terms are combined' do
      input = 'Gender identity disorders--United States'
      expected = 'Gender dysphoria--United States'

      expect(filter.filter(input)).to eq(expected)
    end

    it 'returns nil when input is nil' do
      input = nil
      expected = nil

      expect(filter.filter(input)).to eq(expected)
    end
  end
end
