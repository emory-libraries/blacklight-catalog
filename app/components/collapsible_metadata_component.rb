# frozen_string_literal: true

class CollapsibleMetadataComponent < MetadataComponent
  # @param config [String]
  # @param fields [Enumerable<Blacklight::FieldPresenter>]
  # @param show [Boolean]
  # @param collapse_link_class [String]
  def initialize(config: nil, fields: [], show: false, collapse_link_class: nil)
    @collapse_link_class = collapse_link_class
    keys = config.present? ? YAML.safe_load(File.open(Rails.root.join('config', 'metadata', config))) : []
    fields = filter(fields:, keys:)
    super(fields:, show:)
  end
end
