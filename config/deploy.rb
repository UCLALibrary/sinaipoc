# frozen_string_literal: true

SSHKit.config.command_map[:rake] = "bundle exec rake"

set :application, "sinaipoc"
set :repo_url, "https://github.com/UCLALibrary/sinaipoc.git"

set :deploy_to, '/opt/sinaipoc'
set :rails_env, 'production'

if ENV['VIA_JUMP'] == "yes"
  require 'net/ssh/proxy/command'

  # Define the hostanme of the server to tunnel through
  jump_host = ENV['JUMP_HOST'] || 'jump.library.ucla.edu'

  # Define the port number of the jump host
  jump_port = ENV['JUMP_PORT'] || '31926'

  # Define the username for tunneling
  jump_user = ENV['JUMP_USER'] || ENV['USER']

  # Configure Capistrano to use the jump host as a proxy
  ssh_command = "ssh -p #{jump_port} #{jump_user}@#{jump_host} -W %h:%p"
  set :ssh_options, proxy: Net::SSH::Proxy::Command.new(ssh_command)
end

set :log_level, :debug
set :bundle_flags, "--without=development test"
set :bundle_env_variables, nokogiri_use_system_libraries: 1

set :default_env, 'PASSENGER_INSTANCE_REGISTRY_DIR' => '/var/run'

set :keep_releases, 2
set :passenger_restart_with_touch, true
set :assets_prefix, "#{shared_path}/public/assets"

append :linked_dirs, "log"
append :linked_dirs, "public/assets"
append :linked_dirs, "tmp/pids"
append :linked_dirs, "tmp/cache"
append :linked_dirs, "tmp/sockets"

append :linked_files, ".env.production"
append :linked_files, "config/secrets.yml"

# Default branch is :master
set :branch, ENV['REVISION'] || ENV['BRANCH'] || ENV['BRANCH_NAME'] || 'master'

after "deploy:restart", "sidekiq:restart"
