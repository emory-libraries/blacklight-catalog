# frozen_string_literal: true

namespace :envvars do
  desc 'Load environment variables'
  task :load do
    # Grab the current value of :default_env
    environment = fetch(:default_env, {})

    on roles(:app) do
      # Read in the environment file
      env_file = "/opt/blacklight-catalog/shared/config/environment_variables.yml"
      YAML.safe_load(File.open(env_file)).each { |key, value| environment.store(key, value) } if File.exist?(env_file)

      # Finally, update the global :default_env variable again
      set :default_env, environment
    end
  end
end
