# frozen_string_literal: true

class MetadataComponent < Blacklight::DocumentMetadataComponent
  # @param config [String]
  # @param fields [Enumerable<Blacklight::FieldPresenter>]
  # @param title [String]
  # @param show [Boolean]
  def initialize(config: nil, fields: [], title: '', show: false)
    @title = title
    keys = config.present? ? YAML.safe_load(File.open(Rails.root.join('config', 'metadata', config))) : []
    fields = filter(fields:, keys:)
    super(fields:, show:)
  end

  # @param field Blacklight::FieldPresenter
  def field_component(field)
    field&.component || MetadataFieldComponent
  end

  private

  # @param fields [Enumerable<Blacklight::FieldPresenter>]
  # @param included [String]
  def filter(fields:, keys:)
    return fields if keys.blank?

    fields.select do |field|
      keys.include? field.key
    end
  end
end
