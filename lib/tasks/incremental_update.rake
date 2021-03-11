namespace :blacklight do
  desc "Re-index Blacklight Catalog"
  task reindex: :environment do
    if Rails.env.downcase == 'production'
      oai_set="blacklight"
      puts "oai set is #{oai_set} -- production!"
    else
      oai_set="blacklighttest"
      puts "oai set is #{oai_set} -- dev test qa or stg"
    end
    exec("nohup bundle exec rails marc_index_ingest oai_set_name=#{oai_set} full_index=true | /usr/bin/logger -t blacklight_solr_reindex")
  end

  desc "switch logger to stdout"
  task :to_stdout => [:environment] do
    puts "switching logging to stdout..."
    Rails.logger = Logger.new(STDOUT)
    puts "done."
  end
end

# RAILS_ENV=development nohup bundle exec rails marc_index_ingest oai_set_name=blacklighttest full_index=true > import.log
# RAILS_ENV=production nohup bundle exec rails marc_index_ingest oai_set_name=blacklight > import.log

