# frozen_string_literal: true
class ContentBlock < ApplicationRecord
  validates :reference, presence: true
  delegate :blank?, to: :value
  before_save :sanitize_value

  def self.homepage_banner
    ContentBlock.find_by(reference: 'homepage_banner') || ContentBlock.blank(reference: 'homepage_banner')
  end

  def self.blank(reference:)
    ContentBlock.new(reference:, value: '')
  end

  private

  def sanitize_value
    return unless value.present? && value_changed?

    # Allow only 'a' tags.
    allowed_tags = %w[a]
    # Allow specific attributes for <a> tags.
    allowed_attributes = %w[href target title class id]
    self.value = ActionController::Base.helpers.sanitize(value, tags: allowed_tags, attributes: allowed_attributes)
  end
end
