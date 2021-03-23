# frozen_string_literal: true

class AddlTitlesPresenter
  attr_reader :document, :config

  def initialize(document:)
    @document = document
    @config = YAML.safe_load(File.open(Rails.root.join('config', 'metadata', 'addl_titles.yml')))
  end

  def terms
    @config = @config.symbolize_keys
    keys_to_slice = @config.keys - collapsible_fields
    @document.slice(*keys_to_slice)
  end

  def terms_in_collapsible
    @document.slice(*collapsible_fields)
  end

  def collapsible_fields
    [:title_added_entry_tesim, :title_varying_tesim, :title_abbr_tesim, :title_translation_tesim]
  end
end
