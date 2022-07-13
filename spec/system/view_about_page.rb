# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "View the about page", type: :system do
  it 'has the correct contact links' do
    visit about_path

    expect(page).to have_css('p.static-blurb-body.help-blurb a', text: 'Help & Contacts page')
    expect(page).to have_link('Help & Contacts', class: 'explore-link')
  end
end
