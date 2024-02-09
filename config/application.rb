# frozen_string_literal: true
require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BlacklightCatalog
  class Application < Rails::Application
    # Before filter for Flipflop dashboard. Replace with a lambda or method name
    # defined in ApplicationController to implement access control.
    config.flipflop.dashboard_access_filter = :require_flipflop_access_privileges

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.exceptions_app = routes
    config.autoload_paths += %W[#{config.root}/app/loggers lib/traject]

    # refer to https://github.com/projectblacklight/blacklight/issues/2768
    # refer to https://github.com/projectblacklight/blacklight/pull/2770/files
    config.active_record.yaml_column_permitted_classes = [ActiveSupport::HashWithIndifferentAccess, Symbol]
  end
end
