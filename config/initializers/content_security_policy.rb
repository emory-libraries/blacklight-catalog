# frozen_string_literal: true

Rails.application.config.content_security_policy do |policy|
  policy.frame_ancestors :self, "https://*.emory.edu", "https://na03.alma.exlibrisgroup.com"
end
