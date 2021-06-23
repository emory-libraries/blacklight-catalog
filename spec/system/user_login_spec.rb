# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'User login', type: :system, js: true do
  context "production mode" do
    before do
      allow(AuthConfig).to receive(:use_database_auth?).and_return(false)
    end

    it "does not have dev login options" do
      visit("/")
      click_on("Login")
      ["Uid", "Password"].each do |content|
        expect(page).not_to have_content(content)
      end
      ["Sign in with Shibboleth", "Affiliate login"].each do |link|
        expect(page).to have_link(link)
      end
    end
  end

  context "development mode" do
    around do |example|
      ENV['RAILS_ENV'] = 'development'
      example.run
      ENV['RAILS_ENV'] = 'test'
    end
    it "does have dev login options" do
      expect(ENV['RAILS_ENV']).to eq('development')
      visit("/users/sign_in")
      ["Uid", "Password"].each do |content|
        expect(page).to have_content(content)
      end
      ["Sign in with Shibboleth", "Affiliate login"].each do |link|
        expect(page).not_to have_link(link)
      end
    end
  end
end
