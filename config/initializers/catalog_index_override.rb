# frozen_string_literal: true
# [Blacklight-v7.4.1-overwrite] Overwriting method indexfor the Catalog Controller
# to include an instance variable that contains a hash of real-time availability
# information.

CatalogController.class_eval do
  def index
    (@response, deprecated_document_list) = search_service.search_results

    @document_list = ActiveSupport::Deprecation::DeprecatedObjectProxy.new(deprecated_document_list, 'The @document_list instance variable is deprecated; use @response.documents instead.')
    @documents_availability = AlmaAvailabilityService.new(@response.documents.map(&:id)).availability_of_documents

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
