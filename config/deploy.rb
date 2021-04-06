# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock "~> 3.14.1"

set :application, "blacklight-catalog"
set :repo_url, "git@github.com:emory-libraries/blacklight-catalog.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, ENV['TAG'] || ENV['BRANCH'] || 'main'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/opt/blacklight-catalog"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, ".env.production", "config/secrets.yml"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/assets", "config/emory/groups"

# Default value for default_env is {}
set :default_env,
  PATH: "$PATH:/opt/rh/rh-ruby25/root/usr/local/bin:/opt/rh/rh-ruby25/root/usr/bin",
  LD_LIBRARY_PATH: "$LD_LIBRARY_PATH:/opt/rh/rh-ruby25/root/usr/local/lib64:/opt/rh/rh-ruby25/root/usr/lib64",
  PASSENGER_INSTANCE_REGISTRY_DIR: "/var/run"

# Default value for local_user is ENV['USER']
set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :rails_env, "production"
set :assets_prefix, "#{shared_path}/public/assets"

SSHKit.config.command_map[:rake] = 'bundle exec rake'

namespace :deploy do
  before :migrate, :create_db do
    run("cd /opt/blacklight-catalog/current && RAILS_ENV=production bundle exec rake db:create")
  end
end

set :passenger_restart_with_touch, true
set :ec2_profile, ENV['AWS_PROFILE'] || ENV['AWS_DEFAULT_PROFILE']
set :ec2_region, %w[us-east-1]
set :ec2_contact_point, :private_ip
set :ec2_project_tag, 'EmoryApplicationName'
set :ec2_stages_tag, 'EmoryEnvironment'
