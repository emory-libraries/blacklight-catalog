# frozen_string_literal: true

class DocumentMetadataComponent < Blacklight::DocumentMetadataComponent
  # @param fields [Enumerable<Blacklight::FieldPresenter>]
  # @param show [Boolean]
  # @param path [Pathname]
  def initialize(fields: [], show: false, path: nil)
    @included = path.present? ? YAML.safe_load(File.open(path)).keys : nil
    @fields = filter(fields: fields, included: @included)
    @show = show
    super(fields: @fields, show: @show)
  end

  # @param field Blacklight::FieldPresenter
  def field_component(field)
    field&.component || MetadataFieldComponent
  end

  private

  # @param fields [Enumerable<Blacklight::FieldPresenter>]
  # @param included [String]
  def filter(fields:, included:)
    return fields if included.blank?

    fields.select do |field|
      included.include? field.key
    end
  end
end
