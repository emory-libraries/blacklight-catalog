# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ContentBlock, type: :model do
  it 'validates correctly formatted content blocks' do
    content_block = described_class.new(reference: 'reference', value: 'value')
    expect(content_block.valid?).to be true
  end

  it "validates the presence of reference" do
    content_block = described_class.new(value: 'value')
    expect(content_block.valid?).to be false
  end
end
