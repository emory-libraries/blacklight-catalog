# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'front page', type: :system do
  it 'has expected text' do
    visit "/"
    expect(page).to have_css('h1.jumbotron-heading', text: 'Welcome!')
  end
end
