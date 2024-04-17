[![CircleCI](https://circleci.com/gh/emory-libraries/blacklight-catalog.svg?style=svg)](https://circleci.com/gh/emory-libraries/blacklight-catalog)
[![Test Coverage](https://api.codeclimate.com/v1/badges/a0d9d34d60d7f3ffe2c2/test_coverage)](https://codeclimate.com/github/emory-libraries/blacklight-catalog/test_coverage)

# README

## Blacklight Discovery

* Ruby version 2.7.4

* Rails version 5.1.7

* Blacklight 7.4.1

### Local Development

#### Running locally

1. Clone the git repo: `git clone git@github.com:emory-libraries/blacklight-catalog.git`
1. `cd ./blacklight-catalog`
1. Install the required gems:
    1. `gem install bundler:2.1.4`
    1. `bundle install`
1. Since we're now using MySQL for the database, run `rails db:create`. If you run into errors here, it may be one of two things:
    1. Your local `ENV` variables may not be set correctly. If so, reach out to an already up and running developer for help.
    2. You may have MySQL already configured on your system and set to your own username and passwords. In this case, assign that information into the necessary `ENV` variables and try the create command above once more.
1. If you are still experiencing problems setting up the database, reach out to a software engineer for a screenshare meeting.
1. Migrate the database: `rails db:migrate`
1. Launch development instance of solr in the same folder but a separate terminal window/tab: `bundle exec solr_wrapper`
1. First time running this application locally? Give yourself some test objects by following the directions [here](https://github.com/emory-libraries/blacklight-catalog/blob/main/HARVESTING_ALMA_DATA.md)
1. Start the application: `rails server`
1. You should now be able to go to `http://localhost:3000/catalog` and see the application
1. In order to be able to sign into the application locally, the environment variable DATABASE_AUTH=true must be set in your development environment.
You must create a user via the rails console:
```
  bundle exec rails c
  u = User.new
  u.uid = "user"
  u.display_name = "User Name"
  u.email = "email@testdomain.com"
  u.password = "password"
  u.password_confirmation = "password"
  u.save
```

#### Running Rspec tests locally

1. A separate instance of Solr must be up and running before tests can be run. To do so, run the following command inside your cloned folder: `solr_wrapper --config config/solr_wrapper_test.yml`
1. In a new tab/window within the same folder, run `bundle exec rspec`. All tests should be passing

#### Creating Solr test objects
1. Save the output of the following to a Ruby file in `spec/support/solr_documents`
```
bundle exec rails c
solr = Blacklight.default_index.connection
response = solr.get 'select', params: { q: 'id:YOUR_ID' }
document = response["response"]["docs"].first
document.deep_symbolize_keys!
```
1. Remove `:score` and `:_version_` lines (will not re-save to solr if these are included)
1. Assign to a global variable and add `.freeze` to the end of the hash

#### Using Docker (Experimental)

1. Clone the git repo: `git clone git@github.com:emory-libraries/blacklight-catalog.git`
2. Install Docker using these [instructions](https://docs.docker.com/engine/install/)
3. `cd` into the `blacklight-catalog` repository
4. Set env variables from `dotenv-sample` in a new file `.env.development`. Reach out to a colleague for guidance setting this file since some credentials require additional approvals.
5. Run `docker compose up`
6. Access the application through `http://localhost:3000`

### Troubleshooting
- Error `RSolr::Error::Http - 404 Not Found` occurs while running tests.
    - Solution: The test Solr instance isn't running. You'll know that that Solr is up once you see this complete line: `Starting Solr 7.7.1 on port 8985 ... http://127.0.0.1:8985/solr/`

### Run jmeter page load times test
1. Install and run [Apache Jmeter](https://jmeter.apache.org/) in GUI mode.
1. Open `jmeter/blacklight_catalog.jmx` from the file menu.
1. Hit the green forward arrow to start the tests running.
1. View the immediate results in "View Results Tree" (green with a checkmark for successes, red with an x for failures).
1. If the test suite is ran more than once, results will build in "Aggregate Graph".

### Profiling and Flamegraphs

In development mode, this app uses gems `rack-mini-profiler` and `stackprof` for profiling and generating flamegraphs. To generate a flamegraph, add `?pp=flamegraph` to any page you visit locally, e.g. `http://localhost:3000/?pp=flamegraph` will generate a flamegraph for the home page.

