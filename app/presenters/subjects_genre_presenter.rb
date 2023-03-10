# frozen_string_literal: true

class SubjectsGenrePresenter < FieldPresenter
  CONFIG_PATH = Rails.root.join('config', 'metadata', 'subjects_genre.yml')

  def initialize(fields:)
    super(path: CONFIG_PATH, fields: fields)
  end
end
