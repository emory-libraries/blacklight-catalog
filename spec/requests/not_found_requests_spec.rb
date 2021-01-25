# frozen_string_literal: true
require "rails_helper"

RSpec.describe "404 Error Custom Page", type: :request do
  before { get '/catalog/1' }

  it "loads the page when 404 error detected" do
    expect(response.status).to eq 404
    expect(response.body).not_to be_empty
    expect(response.content_length).to be > 0
    expect(response.content_type).to eq "text/html"
    expect(response).to render_template(:not_found)
  end

  it "contains the requested headers" do
    expect(response.body).to include '404 Error - Page Not Found'
  end
end
