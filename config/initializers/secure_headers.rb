# frozen_string_literal: true
csp_policy = {
  default_src: SecureHeaders::OPT_OUT,
  frame_ancestors: %w['self' https://*.emory.edu https://na03.alma.exlibrisgroup.com],
  script_src: SecureHeaders::OPT_OUT
}

SecureHeaders::Configuration.default do |config|
  config.csp = csp_policy
end
