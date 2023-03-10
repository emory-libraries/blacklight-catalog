# frozen_string_literal: true

class AddlTitlesPresenter < FieldPresenter
  CONFIG_PATH = Rails.root.join('config', 'metadata', 'addl_titles.yml')

  def initialize(fields:)
    super(path: CONFIG_PATH, fields: fields)
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
end
