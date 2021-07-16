# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DeleteOldGuestsService, :clean do
  around do |example|
    User.destroy_all
    Bookmark.destroy_all
    Bookmark.create!(id: 123, user: User.create(id: 123, guest: true, uid: 'guest_123'))
    expect(User.find(123).uid).to eq 'guest_123'
    expect(Bookmark.find(123).user_id).to eq 123
    example.run
    User.destroy_all
    Bookmark.destroy_all
  end

  it 'deletes guest user created 30 mins ago along with their bookmarks' do
    User.update(id: 123, created_at: Time.current - 31.minutes)
    described_class.destroy_users
    expect(User.find_by_id(123).nil?).to eq true
    expect(Bookmark.find_by_id(123).nil?).to eq true
  end

  it 'does not delete guest user created 30 mins ago' do
    User.update(id: 123, created_at: Time.current - 29.minutes)
    described_class.destroy_users
    expect(User.find_by_id(123).nil?).to eq false
    expect(Bookmark.find_by_id(123).nil?).to eq false
  end
end
