# frozen_string_literal: true
class ErrorsController < ApplicationController
  def not_found
    render status: 404
  end

  def unhandled_exception
    render status: 500
  end

  def unprocessable
    render status: 422
  end
end
