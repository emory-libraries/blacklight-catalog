# frozen_string_literal: true

desc "Delete stale searches for NULL and guest users along with their bookmarks"
task delete_old_guests_and_associations: [:environment] do
  DeleteOldGuestsService.destroy_users
  DeleteOldSearchesService.destroy_searches
end
