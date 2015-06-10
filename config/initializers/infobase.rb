require 'infobase'

Infobase.configure do |config|
  config.access_token = ENV.fetch('INFOBASE_TOKEN')
  config.base_url = ENV.fetch('INFOBASE_URL')
end