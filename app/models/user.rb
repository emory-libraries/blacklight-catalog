# frozen_string_literal: true
module OmniAuth
  module Strategies
    # tell OmniAuth to load our strategy
    autoload :Affiliate, 'lib/affiliate_stategy'
  end
end

class User < ApplicationRecord
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  class NilShibbolethUserError < RuntimeError
    attr_accessor :auth

    def initialize(message = nil, auth = nil)
      super(message)
      self.auth = auth
    end
  end

  # Include devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # remove :database_authenticatable in production, remove :validatable to integrate with Shibboleth
  devise_modules = [:omniauthable, :rememberable, :trackable, :timeoutable, omniauth_providers: [:shibboleth, :affiliate], authentication_keys: [:uid]]
  devise_modules.prepend(:database_authenticatable) if AuthConfig.use_database_auth?
  devise(*devise_modules)

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    uid
  end

  # When a user authenticates via shibboleth, find their User object or make
  # a new one. Populate it with data we get from shibboleth.
  # @param [OmniAuth::AuthHash] auth
  def self.from_omniauth(auth)
    Rails.logger.debug "auth = #{auth.inspect}"
    raise User::NilShibbolethUserError.new("No uid", auth) if auth.uid.empty? || auth.info.uid.empty?
    user = User.find_or_initialize_by(provider: auth.provider, uid: auth.info.uid)
    user.assign_attributes(display_name: auth.info.display_name)
    # tezprox@emory.edu isn't a real email address
    user.email = auth.info.uid + '@emory.edu' unless auth.info.uid == 'tezprox'
    user.save
    user
  rescue User::NilShibbolethUserError => e
    Rails.logger.error "Nil user detected: Shibboleth didn't pass a uid for #{e.auth.inspect}"
  end
end
