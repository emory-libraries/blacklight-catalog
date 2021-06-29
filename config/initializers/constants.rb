# frozen_string_literal: true
require 'csv'

def special_collections_locations
  @special_collections_locations ||= begin
    path = Rails.root.join("config", "special_collections_locations.csv")
    file = File.read(path)
    CSV.parse(file, headers: true).map do |row|
      { library_code: row["Library Code (Active)"], location_code: row["Location Code"] }
    end
  end
end

SPECIAL_COLLECTIONS_LOCATIONS = special_collections_locations
