class CreateSolrCacheEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :solr_cache_entries do |t|
      t.string :key
      t.json :value
      t.datetime :expiration_time
    end

    add_index :solr_cache_entries, :key
  end
end
