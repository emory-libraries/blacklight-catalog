# frozen_string_literal: true
class AvailabilityIndicatorsController < ApplicationController
  include Blacklight::Searchable

  def index
    availability_data = AlmaAvailabilityService.new(document_ids).availability_of_documents
    availability_indicators = {}
    documents = search_service.fetch(document_ids, rows: document_ids.count).first.documents
    documents.each do |document|
      availability = availability_data.present? ? availability_data[document.id] : nil
      indicator = render_to_string('catalog/_availability_indicator', layout: false, locals: { xray: false, document: document, doc_avail_values: availability })
      availability_indicators[document.id] = indicator
    end
    render json: availability_indicators
  end

  private

  def document_ids
    availability_indicators_params[:document_ids].first(100).select do |i|
      i.scan(/\D/).empty?
    end
  end

  def availability_indicators_params
    params.permit(document_ids: [])
  end
end
