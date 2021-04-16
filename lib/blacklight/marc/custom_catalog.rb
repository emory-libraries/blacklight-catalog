# frozen_string_literal: true
module Blacklight::Marc
  module CustomCatalog
    extend ActiveSupport::Concern

    def librarian_view
      @response, deprecated_document = search_service.fetch params[:id]
      @document = ActiveSupport::Deprecation::DeprecatedObjectProxy.new(deprecated_document, "The @document instance variable is deprecated and will be removed in Blacklight-marc 8.0")
      respond_to do |format|
        format.html do
          return render layout: false if request.xhr?
          # Otherwise draw the full page
        end
      end
    end

    private

    def render_librarian_view_control?(_config, options = {})
      respond_to? :librarian_view_solr_document_path and options[:document] and options[:document].respond_to?(:to_marc)
    end
  end
end
