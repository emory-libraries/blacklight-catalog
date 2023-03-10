# frozen_string_literal: true

class MainMetadataPresenter < FieldPresenter
  CONFIG_PATH = Rails.root.join('config', 'metadata', 'main_metadata.yml')

  def initialize(fields:)
    super(path: CONFIG_PATH, fields: fields)
  end
end
