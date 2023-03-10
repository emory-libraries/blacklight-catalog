# frozen_string_literal: true

class FieldPresenter
  attr_reader :fields, :config

  def initialize(path:, fields:)
    @config = YAML.safe_load(File.open(path)).symbolize_keys
    @fields = fields
  end

  def terms
    filter(fields: @fields, keys: @config.keys)
  end

  private

  def filter(fields:, keys:)
    fields.select do |field_name, _, _|
      name = field_name.to_sym
      keys.include? name
    end
  end
end
