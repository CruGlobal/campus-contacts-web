unless defined?(FB_API_KEY)
  require Rails.root.join('config','initializers','load_config')
  FB_API_KEY = APP_CONFIG['fb_api_key']
  FB_SECRET = APP_CONFIG['fb_secret']
  FB_APP_ID = APP_CONFIG['fb_app_id']
  FB_HOST = APP_CONFIG['fb_host']
end