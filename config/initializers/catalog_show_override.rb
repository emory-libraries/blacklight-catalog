# frozen_string_literal: true
# [Blacklight-v7.4.1-overwrite] Overwriting method indexfor the Catalog Controller
# to include an instance variable that contains a hash of real-time availability
# information.

CatalogController.class_eval do
  def show
    deprecated_response, @document = search_service.fetch(params[:id])
    @response = ActiveSupport::Deprecation::DeprecatedObjectProxy.new(deprecated_response, 'The @response instance variable is deprecated; use @document.response instead.')
    @documents_availability = AlmaAvailabilityService.new([@document.id]).availability_of_documents
    @physical_holdings = @document.physical_holdings(current_or_guest_user) if Flipflop.enable_requesting_using_api?
    respond_to do |format|
      format.html { @search_context = setup_next_and_previous_documents }
      format.json
      format.xml
      additional_export_formats(@document, format)
    end
  end
end
