require "bundler/capistrano"
require 'hoptoad_notifier/capistrano'
# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :application, "mh"
# set :repository, "http://svn.uscm.org/#{application}/trunk"
set :repository,  "https://github.com/twinge/missionhub.git"
# set :checkout, 'co'
set :keep_releases, '3'

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# primary: true.
# set :target, ENV['target'] || ENV['TARGET'] || 'dev'
default_run_options[:pty] = true
set :scm, "git"
#role :db, "hart-w025.uscm.org", primary: true
#role :web, "hart-w025.uscm.org"
#role :app, "hart-w025.uscm.org"

set :user, 'deploy'
set :password, 'alt60m'


task :staging do
  set :deploy_to, "/var/www/html/integration/#{application}"
  set :environment, 'staging'
  set :rails_env, 'staging'
  
  role :db, "172.16.1.25", primary: true
  role :web, "172.16.1.25"
  role :app, "172.16.1.25"
  set :deploy_via, :remote_cache
end
  
task :production do
  set :deploy_to, "/var/www/html/production/#{application}"
  set :environment, 'production'
  set :rails_env, 'production'
  
  role :db, "172.16.1.126", primary: true
  role :web, "172.16.1.126"
  role :app, "172.16.1.126"
  set :deploy_via, :remote_cache
end


# define the restart task
desc "Restart the web server"
deploy.task :restart, roles: :app do
  # if rails_env == 'production'
    # sudo "/etc/init.d/unicorn upgrade"
  # else
    run "touch #{current_path}/tmp/restart.txt"
  # end
end  


# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
ssh_options[:forward_agent] = true
ssh_options[:port] = 40022

set :branch, "master"
set :deploy_via, :remote_cache
set :git_enable_submodules, true
# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like primary: true)

after 'deploy:update_code', 'local_changes'
desc "Add linked files after deploy and set permissions"
task :local_changes, roles: :app do
  run <<-CMD
    ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
    ln -s #{shared_path}/config/config.yml #{release_path}/config/config.yml &&
    ln -s #{shared_path}/config/initializers/email.rb #{release_path}/config/initializers/email.rb &&
    
    
    mkdir -p -m 770 #{shared_path}/tmp/{cache,sessions,sockets,pids} &&
    rm -Rf #{release_path}/tmp && 
    ln -s #{shared_path}/tmp #{release_path}/tmp 
  CMD
end


# You can use "transaction" to indicate that if any of the tasks within it fail,
# all should be rolled back (for each task that specifies an on_rollback
# handler).

desc "A task demonstrating the use of transactions."
task :long_deploy do
  transaction do
    deploy.update_code
    # deploy.disable_web
    deploy.symlink
    deploy.migrate
  end

  deploy.restart
  # deploy.enable_web
end

before :"deploy:symlink", :"deploy:assets";
namespace :deploy do
  task :assets, roles: :app do
    # run "ln -s #{shared_path}/assets #{release_path}/public/assets"
    run "cd #{release_path} && bundle exec rake assets:precompile RAILS_ENV=#{rails_env}"
  end
end

after "deploy", "deploy:cleanup"
# require 'config/boot'
require 'hoptoad_notifier/capistrano'
