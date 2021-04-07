namespace :blacklight do
  desc "Re-index Blacklight Catalog"
  task reindex: :environment do
    if Rails.env.downcase == 'production'
      oai_set="blacklight"
    else
      oai_set="blacklighttest"
    end
    exec("/usr/local/bin/bundle exec rails marc_index_ingest oai_set_name=#{oai_set} full_index=true | /usr/bin/logger -t blacklight_reindex")
  end
end
