# frozen_string_literal: true

module Admin
  class AdminController < ApplicationController
    authorize_resource class: :admin

    def index; end
  end
end
