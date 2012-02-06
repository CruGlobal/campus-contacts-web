require Rails.root.join('config','initializers','load_config')
Bitly.use_api_version_3
BITLY_CLIENT = Bitly.new(APP_CONFIG['bitly_username'], APP_CONFIG['bitly_key'])
