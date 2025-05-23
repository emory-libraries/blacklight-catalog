# frozen_string_literal: true

namespace :deploy do
  desc 'Ask user for CAB approval before deployment if stage is PROD'
  task :confirm_cab_approval do
    if fetch(:stage) == :PROD
      ask(:cab_acknowledged, 'Have you submitted and received CAB approval? (Yes/No): ')
      unless /^y(es)?$/i.match?(fetch(:cab_acknowledged))
        puts 'Please submit a CAB request and get it approved before proceeding with deployment.'
        exit
      end
    end
  end
end

before 'deploy:starting', 'deploy:confirm_cab_approval'

# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

# Load environment variables
require 'dotenv'

Dotenv.load('.env.development')

set :application, "blacklight-catalog"
set :repo_url, "git@github.com:emory-libraries/blacklight-catalog.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, ENV['TAG'] || ENV['BRANCH'] || 'main'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/opt/blacklight-catalog"

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

# Take this out for now, until i can test without bonking into people
# namespace :deploy do
#  before :migrate, :create_db do
#    run("cd /opt/blacklight-catalog/current && RAILS_ENV=production bundle exec rake db:create")
#  end
# end

set :passenger_restart_with_touch, true

# Restart apache
namespace :deploy do
  after :log_revision, :restart_apache do
    on roles(:web) do
      execute :sudo, :systemctl, :restart, :httpd
    end
  end
end
