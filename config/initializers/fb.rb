unless defined?(FB_SECRET)
  FB_SECRET = ENV.fetch('FB_SECRET')
  FB_APP_ID = ENV.fetch('FB_APP_ID')

  FB_SECRET_MHUB = ENV.fetch('FB_SECRET_MHUB')
  FB_APP_ID_MHUB = ENV.fetch('FB_APP_ID_MHUB')
end
