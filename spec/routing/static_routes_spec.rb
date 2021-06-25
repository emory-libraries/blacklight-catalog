# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Static routes", type: :routing do
  %w[contact about help].each do |x|
    it "routes requests for #{x} to static controller" do
      expect(get("/#{x}")).to route_to(
        controller: "static",
        action: x
      )
    end
  end
end
