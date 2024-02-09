# frozen_string_literal: true
# [Blacklight-Advanced-Search-v7.0.0-overwrite] Overwriting method index
# for the AdvancedController to include dropdown menu options for
# collection facet

BlacklightAdvancedSearch::AdvancedController.class_eval do
  caches_page :index

  def index
    @response = get_advanced_search_facets unless request.method == :post
    collection_auth = Qa::LocalAuthority.find_by(name: 'collections')
    @collection_ssim_facet = Qa::LocalAuthorityEntry.where(local_authority_id: collection_auth).limit(100)&.pluck(:uri) || []
  end
end
