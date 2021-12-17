# frozen_string_literal: true
# [Blacklight-v7.4.1-overwrite] Overwriting method indexfor the Catalog Controller
# to include an instance variable that contains a hash of real-time availability
# information.

CatalogController.class_eval do
  def index
    @response = homepage? ? fetch_cached_search_results : fetch_live_search_results
    @document_list = @response.documents
    @document_ids = @response.documents&.map(&:id) || []

    if @document_list.empty?
      redirect_to "/?empty=true&search_term=#{params[:q]}"
    else
      respond_to do |format|
        format.html { store_preferred_view }
        format.rss  { render layout: false }
        format.atom { render layout: false }
        format.json do
          @presenter = Blacklight::JsonPresenter.new(@response,
                                                     blacklight_config)
        end
        additional_response_formats(format)
        document_export_formats(format)
      end
    end
  end

  private

  def fetch_live_search_results
    search_service.search_results.first
  end

  def fetch_cached_search_results
    solr_cache_entry = SolrCacheEntry.find_by(key: 'catalog/index/homepage_search_results')
    if solr_cache_entry&.unexpired?
      data = JSON.parse(solr_cache_entry.value)
      Blacklight::Solr::Response.new(data, data["responseHeader"]["params"], blacklight_config: blacklight_config)
    else
      solr_cache_entry&.delete
      data = search_service.search_results.first
      SolrCacheEntry.create(key: 'catalog/index/homepage_search_results', value: data.to_json, expiration_time: DateTime.now + 6.hours)
      data
    end
  end

  def homepage?
    query_params = params.keys - ['action', 'controller']
    query_params.empty?
  end
end
