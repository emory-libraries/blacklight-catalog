# frozen_string_literal: true
class DeleteOldGuestsService
  def self.destroy_users
    User.where(["created_at < ? AND uid LIKE 'guest_%'", 30.minutes.ago]).destroy_all
  end
end
