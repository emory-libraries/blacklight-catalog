# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "View the help page", type: :system do
  it 'has the correct ask ejournal link' do
    visit help_path

    expect(
      find('.static-blurb-link', text: 'Ask eJournals')[:href]
    ).to match(/https\W+emory.libwizard.com.f.blacklight.refer.url./)
  end
end
