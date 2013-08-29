require Rails.root.join('config','initializers','fb')
require 'omniauth-facebook_mhub'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
#OmniAuth.config.full_host = 'http://' + ActionMailer::Base.default_url_options[:host]
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, FB_APP_ID, FB_SECRET, scope: 'user_birthday,email,offline_access,user_interests,user_location,user_education_history'
  provider :facebook_mhub, FB_APP_ID_MHUB, FB_SECRET_MHUB, scope: 'user_birthday,email,user_interests,user_location,user_education_history'
end

