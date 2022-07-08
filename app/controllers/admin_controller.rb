# frozen_string_literal: true
class AdminController < ApplicationController
  authorize_resource class: false

  def index; end
end
