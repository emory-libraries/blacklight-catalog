module Devise
  module Models
    module AffiliateAuthenticatable
      extend ActiveSupport::Concern
      def affiliate_authentication(authentication_hash)
      end

      module ClassMethods
        def serialize_from_session(id)
          resource = self.new(id)
          resource
        end
        def serialize_into_session(record)
          [record.uid]
        end
      end
    end
  end
end

module Devise
  module Strategies
    class AffiliateAuthenticatable < Authenticatable

      def authenticate!
        raise "auth_params: #{auth_params}"
        auth_params = authentication_hash
        auth_params[:uid] = uid
        resource = mapping.to.new
        return fail! unless resource

        if validatee(resource){resource.affiliate_authentication(auth_params)}
          success!(resource)
        end
      end
    end
  end
end
