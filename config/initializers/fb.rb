unless defined?(FB_SECRET)
  require Rails.root.join('config','initializers','load_config')
  FB_SECRET = APP_CONFIG['fb_secret']
  FB_APP_ID = APP_CONFIG['fb_app_id']
  
  FB_SECRET_MHUB = APP_CONFIG['fb_secret_mhub']
  FB_APP_ID_MHUB = APP_CONFIG['fb_app_id_mhub']
end