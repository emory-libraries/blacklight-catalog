# frozen_string_literal: true
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
  devise_modules = [:omniauthable, :rememberable, :trackable, :timeoutable, omniauth_providers: [:shibboleth], authentication_keys: [:uid]]
  devise_modules.prepend(:database_authenticatable) if AuthConfig.use_database_auth?
  devise(*devise_modules)

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    uid
  end

  def user_group
    user_info_from_alma.xpath("//user/user_group").text
  end

  def oxford_user?
    oxford_user_group_ids.include?(user_group)
  end

  def oxford_user_group_ids
    %w[23 24 25 26]
  end

  def user_info_from_alma
    @user_info_from_alma ||= Nokogiri.XML(RestClient.get(alma_user_url).body)
  end

  def alma_user_url
    "#{ENV['ALMA_API_URL']}/almaws/v1/users/#{uid}?user_id_type=all_unique&view=full&expand=none&apikey=#{ENV['ALMA_USER_KEY']}"
  end

  def doc_delivery?
    return false if guest
    doc_delivery_user_group_ids.include?(user_group)
  end

  def doc_delivery_user_group_ids
    %w[01 02 03 04 09 10 12 20 22 23 24 25]
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
