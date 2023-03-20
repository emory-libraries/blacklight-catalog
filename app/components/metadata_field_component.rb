# frozen_string_literal: true

class MetadataFieldComponent < Blacklight::MetadataFieldComponent
  # @param field [Blacklight::FieldPresenter]
  # @param layout [Blacklight::MetadataFieldLayoutComponent]
  # @param show [Boolean]
  def initialize(field:, layout: nil, show: false)
    layout ||= MetadataFieldLayoutComponent
    super(field: field, layout: layout, show: show)
  end
end
