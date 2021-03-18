# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ShowPageHelper, type: :helper do
  let(:value) { SHOW_PAGE_VALUE }
  let(:multivalue) do
    dupe = SHOW_PAGE_VALUE.dup
    dupe[:document][dupe[:field]] = 'http://www.example.com', 'http://www.example.com/2'
    dupe
  end

  context '#convert_solr_value_to_url' do
    it 'converts a single value to an anchor tag' do
      expect(helper.convert_solr_value_to_url(value)).to eq(
        "<a href=\"http://www.example.com\" target=\"_blank\" rel=\"noopener noreferrer\">http://www.example.com</a>"
      )
    end

    it 'converts a multiple values into two anchor tags separated by a breakline' do
      expect(helper.convert_solr_value_to_url(multivalue)).to eq(
        "<a href=\"http://www.example.com\" target=\"_blank\" rel=\"noopener noreferrer\">http://www.example.com</a>" \
          "<br /><a href=\"http://www.example.com/2\" target=\"_blank\" rel=\"noopener noreferrer\">http://www.example.com/2</a>"
      )
    end
  end

  context '#multiple_values_new_line' do
    it 'converts a multiple values into two values separated by a breakline' do
      expect(helper.multiple_values_new_line(multivalue)).to eq(
        "http://www.example.com<br />http://www.example.com/2"
      )
    end
  end
end
