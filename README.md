# README

## Blacklight Discovery

* Ruby version 2.5.7p206

* Rails version 5.1.7

* Blacklight 7.4.1

## Running locally

1. Clone the git repo: `git clone git@github.com:emory-libraries/blacklight-catalog.git`
1. `cd ./blacklight-catalog`
1. Install the required gems: `bundle install`
1. Migrate the database: `rails db:migrate`
1. Launch development instance of solr in the same folder but a separate terminal window/tab: `bundle exec solr_wrapper`
1. First time running this application locally? Give yourself some test objects: `rake solr:marc:index_test_data`
1. Start the application: `rails server`
1. You should now be able to go to `http://localhost:3000/catalog` and see the application

## Running Rspec tests locally

1. A separate instance of Solr must be up and running before tests can be run. To do so, run the following command inside your cloned folder: `solr_wrapper --config config/solr_wrapper_test.yml`
1. In a new tab/window within the same folder, run `bundle exec rspec`. All tests should be passing

## Troubleshooting
- Error `RSolr::Error::Http - 404 Not Found` occurs while running tests.
    - Solution: The test Solr instance isn't running. You'll know that that Solr is up once you see this complete line: `Starting Solr 7.7.1 on port 8985 ... http://127.0.0.1:8985/solr/`