# frozen_string_literal: true
require "rails_helper"
# rubocop:disable RSpec/AnyInstance
RSpec.describe ErrorsController, type: :request do
  before do
    allow(Rails.application.config).to receive(:consider_all_requests_local).and_return(false)
  end
  it "loads the page when 500 error detected" do
    allow_any_instance_of(CatalogController).to receive(:show).and_raise("Whoa Beavis!")
    get '/catalog/1'
    expect(response.status).to eq 500
    expect(response.body).not_to be_empty
    expect(response.content_length).to be > 0
    expect(response.content_type).to eq "text/html"
    expect(response).to render_template(:unhandled_exception)
  end
  it "loads the page when 422 error detected" do
    allow_any_instance_of(CatalogController).to receive(:show).and_raise(ActionController::InvalidAuthenticityToken)
    get '/catalog/1'
    expect(response.status).to eq 422
    expect(response.body).not_to be_empty
    expect(response.content_length).to be > 0
    expect(response.content_type).to eq "text/html"
    expect(response).to render_template(:unprocessable)
  end

  it "loads the page when 404 error detected" do
    get '/catalog/1'
    expect(response.status).to eq 404
    expect(response.body).not_to be_empty
    expect(response.content_length).to be > 0
    expect(response.content_type).to eq "text/html"
    expect(response).to render_template(:not_found)
  end
end
