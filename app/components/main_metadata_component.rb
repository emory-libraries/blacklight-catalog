# frozen_string_literal: true

class MainMetadataComponent < DocumentMetadataComponent
  CONFIG_PATH = Rails.root.join('config', 'metadata', 'main_metadata.yml')

  # @param fields [Enumerable<Blacklight::FieldPresenter>]
  # @param show [Boolean]
  def initialize(fields: [], show: false)
    super(fields: fields, show: show, path: CONFIG_PATH)
  end
end
