# frozen_string_literal: true

class Qa::LocalAuthorityEntry < ApplicationRecord
  belongs_to :local_authority

  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :uri, uniqueness: true
  # rubocop:enable Rails/UniqueValidationWithoutIndex
end
