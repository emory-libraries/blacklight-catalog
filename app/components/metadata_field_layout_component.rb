# frozen_string_literal: true

class MetadataFieldLayoutComponent < Blacklight::MetadataFieldLayoutComponent
  # @param field [Blacklight::FieldPresenter]
  # @param label_class [String]
  # @param value_class [String]
  def initialize(field:, label_class: 'col-md-4', value_class: 'col-md-8')
    super(field: field, label_class: label_class, value_class: value_class)
  end

  def before_render
    @value_class = value_class + " truncate" if helpers.blacklight_config.truncate_field_values.include? @field.key
  end
end
