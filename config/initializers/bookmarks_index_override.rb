# frozen_string_literal: true
# [Blacklight-v7.4.1-overwrite]

BookmarksController.class_eval do
  def index
    @bookmarks = token_or_current_or_guest_user.bookmarks
    bookmark_ids = @bookmarks.collect { |b| b.document_id.to_s }
    @response, deprecated_document_list = search_service.fetch(bookmark_ids)
    @document_list = ActiveSupport::Deprecation::DeprecatedObjectProxy.new(deprecated_document_list, "The @document_list instance variable is now deprecated and will be removed in Blacklight 8.0")
    @document_ids = @response.documents&.map(&:id) || []

    respond_to do |format|
      format.html {}
      format.rss  { render layout: false }
      format.atom { render layout: false }
      format.json do
        render json: render_search_results_as_json
      end

      additional_response_formats(format)
      document_export_formats(format)
    end
  end
end
