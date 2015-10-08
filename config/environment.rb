# Load the rails application
require File.expand_path('../application', __FILE__)
require 'rack/oauth2/server/railtie'

# Initialize the rails application
Rails.application.initialize!

# if defined?(PhusionPassenger)
#   PhusionPassenger.on_event(:starting_worker_process) do |forked|
#     # Only works with DalliStore
#     Rails.cache.reset if forked
#   end
# end
