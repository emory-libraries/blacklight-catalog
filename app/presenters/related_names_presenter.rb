# frozen_string_literal: true

class RelatedNamesPresenter
  attr_reader :document, :config

  def initialize(fields:)
    @config = YAML.safe_load(File.open(Rails.root.join('config', 'metadata', 'related_names.yml'))).symbolize_keys
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
