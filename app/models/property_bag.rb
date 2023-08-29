# frozen_string_literal: true
class PropertyBag < ApplicationRecord
  self.pluralize_table_names = false

  def self.get(name)
    find_by(name:).value
  rescue
    nil
  end

  def self.set(name, value)
    find_or_create_by(name:).tap do |prop|
      prop.name = name
      prop.value = value
      prop.save!
    end
  end
end
