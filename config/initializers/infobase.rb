require 'infobase'

Infobase.configure do |config|
  config.access_token = APP_CONFIG['infobase_token']
  config.base_url = APP_CONFIG['infobase_url']
end