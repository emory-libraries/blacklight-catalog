# frozen_string_literal: true

class DescriptionSummaryPresenter < FieldPresenter
  CONFIG_PATH = Rails.root.join('config', 'metadata', 'description_summary.yml')

  def initialize(fields:)
    super(path: CONFIG_PATH, fields: fields)
  end
end
