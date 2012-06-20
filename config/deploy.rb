# require 'new_relic/recipes'
require "bundler/capistrano"
require 'airbrake/capistrano'
#load 'deploy/assets'
set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"
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
set :repository,  "git@git.uscm.org:missionhub.git"
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

task :staging do
  set :deploy_to, "/var/www/html/staging/#{application}"
  set :environment, 'staging'
  set :rails_env, 'staging'
servers = ["108.171.184.122"]
  role :db, servers.first, primary: true
  role :web, *servers
  role :app, *servers
  set :deploy_via, :remote_cache
end

#task :staging do
  #set :deploy_to, "/var/www/html/integration/#{application}"
  #set :environment, 'staging'
  #set :rails_env, 'staging'
  
  #role :db, "172.16.1.25", primary: true
  #role :web, "172.16.1.25"
  #role :app, "172.16.1.25"
  #set :deploy_via, :remote_cache
#end

task :fast do
  set :deploy_to, "/var/www/#{application}"
  set :environment, 'production'
  set :rails_env, 'production'
  
  role :db, "10.10.11.167", primary: true
  role :web, "10.10.11.167"
  role :app, "10.10.11.167"
  set :deploy_via, :remote_cache
end
  
task :production do
  set :deploy_to, "/var/www/html/production/#{application}"
  set :environment, 'production'
  set :rails_env, 'production'

  
  server "50.56.172.42", :web, :app, :db, primary: true
  set :deploy_via, :remote_cache
end


deploy.task :restart, :roles => [:app], :except => {:no_release => true} do
  if rails_env == 'production'
    servers = find_servers_for_task(current_task)
    servers.map do |s|
      run "cd #{deploy_to}/current && echo '' > public/lb.html", :hosts => s.host
      run "touch #{current_path}/tmp/restart.txt", :hosts => s.host
      #sleep 60
      run "cd #{deploy_to}/current && echo 'ok' > public/lb.html", :hosts => s.host
    end
  else
    run "touch #{current_path}/tmp/restart.txt"#, :hosts => s.host
  end
end


before 'deploy:restart', 'deploy:bluepill'
deploy.task :bluepill, roles: :db do
  if rails_env == 'production'
    sudo "bluepill restart resque"
  end
end


# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
ssh_options[:forward_agent] = true
ssh_options[:port] = 40022

if ENV['branch']
  set :branch, ENV['branch']
else
  set :branch, "master"
end

set :deploy_via, :remote_cache
set :git_enable_submodules, true
set :use_sudo, false
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
    ln -s #{shared_path}/config/s3.yml #{release_path}/config/s3.yml &&
    ln -s #{shared_path}/config/initializers/email.rb #{release_path}/config/initializers/email.rb &&
    
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
# after "deploy:update", "newrelic:notice_deployment"
after :"local_changes", :"assets:precompile";
namespace :assets do
  task :precompile, roles: :web do
    run "ln -s #{shared_path}/assets #{release_path}/public/assets"
    run "cd #{release_path} && bundle exec rake assets:precompile RAILS_ENV=#{rails_env}"
  end

  task :cleanup, :roles => :web do
    run "cd #{current_path} && RAILS_ENV=production bundle exec rake assets:clean"
  end
end

if rails_env == 'production'
  after "deploy:symlink", "deploy:migrate"
end
after "deploy", "deploy:cleanup"
# require 'config/boot'
