# frozen_string_literal: true
class SolrCacheEntry < ApplicationRecord
  validates :key, :value, :expiration_time, presence: true
  scope :unexpired, -> { where('expiration_time > ?', DateTime.now) }

  def unexpired?
    expiration_time > DateTime.now
  end
end
