class AffiliateUser
  include ActiveModel::Validations
  extend ActiveModel::Callbacks
  include ActiveModel::Serialization
  extend Devise::Models
  attr_accessor :uid

  def attributes
    {:uid=>uid}
  end

  define_model_callbacks :validation
  devise :affiliate_authenticatable
  def initialize(uid)
    self.uid = uid
  end

end
