# README

## Blacklight Discovery

* Ruby version 2.5.7p206

* Rails version 5.1.7

* Blacklight 7.4.1

## Running locally

1. Clone the git repo: `git@github.com:emory-libraries/blacklight-catalog.git`
1. `cd ./blacklight-catalog`
1. Install the required gems: `bundle install`
1. Migrate the database: `rails db:migrate`
1. Launch development instance of solr in the same folder but a separate terminal window/tab: `bundle exec solr_wrapper`
1. First time running this application locally? Give yourself some text objects: `rake solr:marc:index_test_data`
1. Start the application: `rails server`
1. You should now be able to go to `http://localhost:3000/catalog` and see the application