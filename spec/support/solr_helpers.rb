# frozen_string_literal: true

module SolrHelpers
  def delete_all_documents_from_solr
    solr_spec_connection.delete_by_query('*:*')
    solr_spec_connection.commit
  end

  def build_solr_docs(docs)
    solr_spec_connection.add(docs)
    solr_spec_connection.commit
  end

  def solr_spec_connection
    Blacklight.default_index.connection
  end

  RSpec.configure do |config|
    config.include SolrHelpers
  end
end
