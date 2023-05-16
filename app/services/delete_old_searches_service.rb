# frozen_string_literal: true
class DeleteOldSearchesService
  def self.destroy_searches
    log_file = Rails.env.production? ? "log/production.log" : "log/development.log"
    Rails.logger = Logger.new(log_file)
    start = DateTime.now
    Rails.logger.info "Deleting all Searches where User is NULL"
    Search.where(["created_at < ? AND user_id IS NULL", 1.day.ago]).destroy_all
    Rails.logger.info "Search deletion started at #{start} and finished at #{DateTime.now}."
  end
end
