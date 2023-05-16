# frozen_string_literal: true
class DeleteOldGuestsService
  def self.destroy_users
    log_file = Rails.env.production? ? "log/production.log" : "log/development.log"
    Rails.logger = Logger.new(log_file)
    start = DateTime.now
    Rails.logger.info "Deleting all Guest users along with their bookmarks"
    User.where(["created_at < ? AND uid LIKE 'guest_%'", 1.day.ago]).destroy_all
    Rails.logger.info "Guest deletion started at #{start} and finished at #{DateTime.now}."
  end
end
