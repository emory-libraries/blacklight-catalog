# frozen_string_literal: true

class RelatedNamesPresenter < FieldPresenter
  CONFIG_PATH = Rails.root.join('config', 'metadata', 'related_names.yml')

  def initialize(fields:)
    super(path: CONFIG_PATH, fields: fields)
  end
end
