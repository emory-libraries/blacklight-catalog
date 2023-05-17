# frozen_string_literal: true
class DeleteOldSearchesService
  def self.destroy_searches
    log_file = Rails.env.production? ? "log/production.log" : "log/development.log"
    Rails.logger = Logger.new(log_file)
    start = DateTime.now
    Rails.logger.info "Deleting all Searches where User is NULL"
    Search.delete_old_searches(1)
    Rails.logger.info "Search deletion started at #{start} and finished at #{DateTime.now}."
  end
end
