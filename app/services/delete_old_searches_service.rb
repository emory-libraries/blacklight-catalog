# frozen_string_literal: true
class DeleteOldSearchesService
  def self.destroy_searches
    Search.where(["created_at < ? AND user_id IS NULL", 30.minutes.ago]).destroy_all
  end
end
