# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  protect_from_forgery with: :exception

  def alma_availability
    availability = AlmaAvailabilityService.new(params[:id])&.current_availability

    respond_to { |format| format.any { render json: availability } }
  end
end
