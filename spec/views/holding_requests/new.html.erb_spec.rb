# frozen_string_literal: true
require "rails_helper"

RSpec.describe "holding_requests/new", type: :view do
  it "renders a form with stuff in it" do
    assign(:holding_request, HoldingRequest.new(mms_id: "abc"))
    render template: 'holding_requests/new'
    expect(rendered).to match(/Pickup library/)
    expect(rendered).to match(/Not needed after/)
    expect(rendered).to match(/Comment/)
  end
end
