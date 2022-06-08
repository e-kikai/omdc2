# config valid only for current version of Capistrano
# lock '3.8.1'
lock '3.17.0'

set :application, 'omdc2'
set :repo_url, 'git@github.com:e-kikai/omdc2.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/omdc2'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :linked_files, %w{config/database.yml config/secrets.yml}

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
# set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets tmp/vbpr vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
set :keep_releases, 5

set :default_env, {
  # rbenv_root: "/usr/local/rbenv",
  # path: "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH"

  rbenv_root: "~/.rbenv/",
  path: "~/.rbenv/shims:~/.rbenv/bin:$PATH"

}

# 共有ディレクトリにSymlinkする対象を追加
# set :linked_dirs, (fetch(:linked_dirs) + ['tmp/pids'])

# Unicorn周りの設定をする
set :unicorn_rake_env, "none"
set :unicorn_config_path, 'config/unicorn.rb'

after 'deploy:publishing', 'deploy:restart'

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      invoke 'unicorn:restart'
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
