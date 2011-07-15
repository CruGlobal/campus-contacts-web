require 'resque/server'

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')
Resque.redis = resque_config[rails_env]

if APP_CONFIG['resque_username']
  Resque::Server.use Rack::Auth::Basic do |username, password|
    username == APP_CONFIG['resque_username']
    password == APP_CONFIG['resque_password']
  end
end