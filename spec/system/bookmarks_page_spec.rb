# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Bookmarks page', type: :system do
  let(:user) { User.create(uid: "janeq") }

  it 'loads page without error once user signed in' do
    sign_in(user)
    visit bookmarks_path

    expect(page).to have_css('h1.page-heading.bookmarks.show-header', text: 'Bookmarks')
  end
end
