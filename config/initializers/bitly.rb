require Rails.root.join('config','initializers','load_config')
# Bitly.use_api_version_3
Bitly.use_api_version_3
Bitly.configure do |config|
  config.api_version = 3
  config.access_token = APP_CONFIG['bitly_key']
end
# BITLY_CLIENT = Bitly.new(APP_CONFIG['bitly_username'], APP_CONFIG['bitly_key'])
# Bitly.configure do |config|
#   config.api_version = 3
#   config.access_token = APP_CONFIG['bitly_key']
# end