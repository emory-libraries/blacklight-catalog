class MakeSolrCacheEntriesKeyUnique < ActiveRecord::Migration[5.1]
  def change
    remove_index :solr_cache_entries, :key
    add_index :solr_cache_entries, :key, unique: true
  end
end
