# frozen_string_literal: true
class DeleteOldGuestsService
  def self.destroy_users
    log_file = Rails.env.production? ? "log/production.log" : "log/development.log"
    Rails.logger = Logger.new(log_file)
    # Whenever we upgrade Blacklight, we need to ensure all data associated to guests is deleted properly
    # whenever guest users are deleted. For now, only bookmarks and searches are deleted.
    start = DateTime.now
    Rails.logger.info "Deleting all Guest users along with their bookmarks"
    Bookmark.where(["user_id IN (SELECT id FROM `users` WHERE (created_at < ? AND uid LIKE 'guest_%') )", 1.day.ago]).delete_all
    Search.where(["user_id IN (SELECT id FROM `users` WHERE (created_at < ? AND uid LIKE 'guest_%') )", 1.day.ago]).delete_all
    User.where(["created_at < ? AND uid LIKE 'guest_%'", 1.day.ago]).delete_all
    Rails.logger.info "Guest deletion started at #{start} and finished at #{DateTime.now}."
  end
end
