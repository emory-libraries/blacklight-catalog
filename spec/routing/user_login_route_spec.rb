# frozen_string_literal: true
require "rails_helper"

RSpec.describe "User login page", type: :routing do
  it "loads user login page" do
    expect(get("/sign_in")).to route_to(controller: "sessions", action: "new")
  end
end
