# frozen_string_literal: true

namespace :envvars do
  desc 'Load environment variables'
  task :load do
    on roles("web") do
      execute "cp -v /opt/blacklight-catalog/shared/config/environment_variables /opt/blacklight-catalog/current/.env.production"
    end
  end
end
