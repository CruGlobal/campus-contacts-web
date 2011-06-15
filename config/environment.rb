# Load the rails application
require File.expand_path('../application', __FILE__)
require "rack/oauth2/server/railtie"

# Initialize the rails application
Mh::Application.initialize!
