# frozen_string_literal: true
class DeleteOldGuestsService
  def self.destroy_users
    log_file = Rails.env.production? ? "log/production.log" : "log/development.log"
    Rails.logger = Logger.new(log_file)
    Rails.logger.info "Deleting all Guest users along with their bookmarks"
    User.where(["created_at < ? AND uid LIKE 'guest_%'", 30.minutes.ago]).destroy_all
  end
end
