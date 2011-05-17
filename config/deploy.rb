require 'bundler/capistrano'

set :application, "project_zero"

role :app, "ghostwriter.panter.ch"
role :web, "ghostwriter.panter.ch"
role :db,  "ghostwriter.panter.ch", :primary => true
set :rails_env, 'production'

set :deploy_via, :remote_cache
set :git_enable_submodules, 1
set :scm, :git
set :default_run_options, { :pty => true }
set :repository, "gitosis@git.panter.ch:ghostwriter.git"
set :ssh_options, {:forward_agent => true}
set :deploy_to, "/home/gwriter/ghostwriter.panter.ch"
set :user, "gwriter"
set :use_sudo, false

task :update_config_links, :roles => [:app] do
  run "ln -sf #{shared_path}/config/* #{release_path}/config/"
end
after "deploy:update_code", :update_config_links

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after "deploy", "deploy:cleanup"
