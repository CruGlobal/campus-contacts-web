require Rails.root.join('config','initializers','load_config')

Bitly.use_api_version_3
Bitly.configure do |config|
  config.api_version = 3
  config.access_token = ENV.fetch('BITLY_KEY')
end
