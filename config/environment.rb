# Load the rails application
require File.expand_path('../application', __FILE__)
require "rack/oauth2/server/railtie"

# Initialize the rails application
Mh::Application.initialize!

# configure rack-oauth2-server
Mh::Application.configure do
  # config.after_initialize do
  #   # integrate with devise
  #   config.oauth.authenticator = lambda do |email, password|
  #     user = User.find_for_database_authentication(:email => email)
  #     user if user && user.valid_password?(password)
  #     user.userID
  #   end
  #   config.oauth.param_authentication = TRUE
  #   Rack::OAuth2::Server::Admin.set :client_id, "2"
  #   Rack::OAuth2::Server::Admin.set :client_secret, "e6f0bc02c1236f3d4cde6a4fd45e181569a8abf45ce17a3dba2fd88fe55722b6"
  #   
  # end
end
