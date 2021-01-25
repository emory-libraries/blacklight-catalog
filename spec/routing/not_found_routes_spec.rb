# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Not Found Routes", type: :routing do
  it "routes requests for 404 to the static controller action not_found" do
    expect(get("/404")).to route_to(
      controller: "static",
      action: "not_found"
    )
  end
end
