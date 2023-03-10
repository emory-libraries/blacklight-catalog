# frozen_string_literal: true

class AddlIdsPresenter < FieldPresenter
  CONFIG_PATH = Rails.root.join('config', 'metadata', 'addl_ids.yml')

  def initialize(fields:)
    super(path: CONFIG_PATH, fields: fields)
  end
end
