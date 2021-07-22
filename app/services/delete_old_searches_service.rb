# frozen_string_literal: true
class DeleteOldSearchesService
  def self.destroy_searches
    log_file = Rails.env.production? ? "log/production.log" : "log/development.log"
    Rails.logger = Logger.new(log_file)
    Rails.logger.info "Deleting all Searches where User is NULL"
    Search.where(["created_at < ? AND user_id IS NULL", 30.minutes.ago]).destroy_all
  end
end
