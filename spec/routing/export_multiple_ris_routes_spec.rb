# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Export Multiple RIS Routes", type: :routing do
  it "routes requests for export multiple RIS with a string of comma-separated MMS IDs" do
    expect(get("/export_multiple_ris/mms-ids")).to route_to(
      controller: "export_ris",
      action: "export_multiple_ris",
      ids: "mms-ids"
    )
  end
end
