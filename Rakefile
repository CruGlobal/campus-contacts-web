# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'resque/tasks'
# require 'simplecov'
# SimpleCov.start 'rails' do
#   add_filter "vendor"
#   merge_timeout 36000
# end
Mh::Application.load_tasks
