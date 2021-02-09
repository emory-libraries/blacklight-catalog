# frozen_string_literal: true

class MainMetadataPresenter
  attr_reader :document, :config

  def initialize(document:)
    @document = document
    @config = YAML.safe_load(File.open(Rails.root.join('config', 'metadata', 'main_metadata.yml')))
  end

  def terms
    @config = @config.symbolize_keys
    @document.slice(*@config.keys)
  end
end
