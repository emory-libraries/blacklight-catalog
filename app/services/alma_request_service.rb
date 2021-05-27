# frozen_string_literal: true
require 'rest-client'
require 'nokogiri'

class AlmaRequestService
  def initialize(mms_id, uid)
    @mms_id = mms_id
    # @response = query_holding
    # @xml = Nokogiri::XML(@response)
  end
end
