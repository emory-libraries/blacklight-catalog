# frozen_string_literal: true
require 'omniauth/core'

module OmniAuth
  module Strategies
    class Affiliate
      include OmniAuth::Strategy

      def initialize(app, app_id = nil, api_key = nil, options = {})
        opts = {
          :site               => "/",
          :request_token_path => "",
          :access_token_path  => "",
          :authorize_url      => "/affiliate"
        }
        super(app, :affiliate, app_id, api_key, opts, options)
      end

      protected

      def request_phase
        r = Rack::Response.new
        r.redirect 'users/affiliate'
        r.finish
      end

      def callback_phase
        if request.params["uid"].present? && request.params["password"].present?
          @uid, @password = request.params["uid"], request.params["password"]
          super
        else
    # OmniAuth takes care of the rest
          fail!(:invalid_credentials)
        end
      end

      # normalize user's data according to http://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
      def auth_hash
        OmniAuth::Utils.deep_merge(super(), {
          'uid' => @uid,
          'password' => @password
        })
      end
    end
  end
end
