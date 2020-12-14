# Using SolrMarc To Harvest Data From Alma Into Solr Index

### Follow this guide to get a representative sample of Alma records into your local Solr instance.

1. Follow the instructions in the main `README.md` to set up the basic Blacklight application locally.
2. At the root level of the project directory, create a `.env.development` file with the following environment variables:
```
# provide alma domain for oai base url fetch
alma="na03"
# provide institution for oai base url fetch
institution="01GALI_EMORY"
# provide SOLR_URL for solr connections
SOLR_URL="http://localhost:8983/solr/blacklight-core"
# provides name for oai set being fetched
oai_set_name="blacklighttest"
```
3. Connect to `vpnproxy.emory.edu` using Big-IP Edge Client.
4. Run the rake task:
  - If the default set is desired, run `RAILS_ENV=development bundle exec rails oai_harvest` in your terminal.
  - If there is a specific OAI set that is preferred over `blacklighttest`, add the `oai_set_name` variable assignment to the command:
    `RAILS_ENV=development bundle exec rails oai_harvest oai_set_name=<name of preferred set>`
  - Either command may take several minutes to process.
5. In your local [Solr instance](http://localhost:8983/solr/#/blacklight-core/query), perform a global search query. The default subset collection contains roughly 4500 items.

This tutorial can also be found at this [link](https://wiki.emory.edu/display/BDL/Using+SolrMarc+to+harvest+data+from+Alma+into+Solr+Index) (Emory login required).