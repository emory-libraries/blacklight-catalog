# frozen_string_literal: true
class StaticController < ApplicationController
  def not_found
    render status: 404
  end
end
