# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Alma Availability Routes", type: :routing do
  it "routes requests for alma availability with a MMS ID" do
    expect(get("/alma_availability/mms-id")).to route_to(
      controller: "application",
      action: "alma_availability",
      id: "mms-id"
    )
  end
end
