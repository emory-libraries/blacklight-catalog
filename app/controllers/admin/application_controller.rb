# frozen_string_literal: true
module Admin
  class ApplicationController < Administrate::ApplicationController
    before_action :authenticate_admin

    def authenticate_admin
      can? :manage, :admin
    end

    def show_action?(action, resource)
      can? action, resource
    end
  end
end
