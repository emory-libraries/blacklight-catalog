# frozen_string_literal: true
namespace :blacklight do
  desc "Re-index Blacklight Catalog"
  task reindex: :environment do
    oai_set = Rails.env.production? ? "blacklight" : "blacklighttest"
    ingest_processed = system("/usr/local/bin/bundle exec rails marc_index_ingest oai_set_name=#{oai_set} | /usr/bin/logger -t blacklight_reindex")
    Honeybadger.check_in(ENV['HONEYBADGER_BLACKLIGHT_REINDEX_CHECK_IN_ID']) if ingest_processed && Rails.env.production?
  end
end
