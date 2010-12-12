require 'resque/server'
if APP_CONFIG['resque_username']
  Resque::Server.use Rack::Auth::Basic do |username, password|
    username == APP_CONFIG['resque_username']
    password == APP_CONFIG['resque_password']
  end
end