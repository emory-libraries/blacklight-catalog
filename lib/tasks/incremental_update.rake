namespace :blacklight do
  desc "Re-index Blacklight Catalog"
  task reindex: :environment do
    #puts "working dir: #{Rails.root}"
    exec('nohup bundle exec rails marc_index_ingest oai_set_name=blacklighttest full_index=true')
  end
end

# RAILS_ENV=development nohup bundle exec rails marc_index_ingest oai_set_name=blacklighttest full_index=true > import.log
# RAILS_ENV=production nohup bundle exec rails marc_index_ingest oai_set_name=blacklight > import.log

