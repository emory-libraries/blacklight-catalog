# frozen_string_literal: true

class Qa::LocalAuthorityEntry < ApplicationRecord
  belongs_to :local_authority
  validates :uri, uniqueness: true
end
