# frozen_string_literal: true
class CollectionsController < ApplicationController
  def search
    @collection_result = Qa::LocalAuthorityEntry.where("uri LIKE lower(?)", "#{params[:uri].downcase}%").limit(10)&.pluck(:uri) || []
    render json: { collection_result: @collection_result }
  end
end
