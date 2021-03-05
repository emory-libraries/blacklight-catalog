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
```
3. Connect to `vpnproxy.emory.edu` using Big-IP Edge Client.
4. Run the rake task:
  - If the production set (4.9~ million) is desired, run 
    `RAILS_ENV=development bundle exec rails marc_index_ingest oai_set_name=blacklight full_index=true` 
    in your terminal. This will take over twelve hours to process, so be cautious using this set locally.
  - If you'd like a more manageable set (4.6~ thousand) for testing purposes, run the command below:
    `RAILS_ENV=development bundle exec rails marc_index_ingest oai_set_name=blacklighttest full_index=true`
  - Note: The commands above can be used to re-index (update) your local Solr instance. To re-index only the 
    items that have changed since the last harvest, remove the argument `full_index=true` completely.
  - If you want to re-index a single item, remove `full_index=true`, `oai_set_name` and add `oai_single_id=some_msid`
    with an id of the record you want to re-index.
5. In your local [Solr instance](http://localhost:8983/solr/#/blacklight-core/query), perform a global search query. You will start to see records accumulate when refreshing the page multiple times.

This tutorial can also be found at this [link](https://wiki.emory.edu/display/BDL/Using+SolrMarc+to+harvest+data+from+Alma+into+Solr+Index) (Emory login required).