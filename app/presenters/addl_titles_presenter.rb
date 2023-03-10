# frozen_string_literal: true

class AddlTitlesPresenter
  attr_reader :document, :config

  def initialize(fields:)
    @config = YAML.safe_load(File.open(Rails.root.join('config', 'metadata', 'addl_titles.yml'))).symbolize_keys
    @fields = fields
  end

  def terms
    keys = @config.keys - collapsible_field_keys
    filter(fields: @fields, keys: keys)
  end

  def terms_in_collapsible
    filter(fields: @fields, keys: collapsible_field_keys)
  end

  def collapsible_field_keys
    [:title_added_entry_tesim, :title_varying_tesim, :title_abbr_tesim, :title_translation_tesim]
  end

  private

  def filter(fields:, keys:)
    fields.select do |field_name, _, _|
      name = field_name.to_sym
      keys.include? name
    end
  end
end
