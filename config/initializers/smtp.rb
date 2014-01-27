require Rails.root.join('config','initializers','load_config').to_s
ActionMailer::Base.smtp_settings = {
  :user_name => APP_CONFIG['smtp_user_name'],
  :password => APP_CONFIG['smtp_password'],
  :address => APP_CONFIG['smtp_address'],
  :authentication => (APP_CONFIG['smtp_authentication'] || :none),
  :enable_starttls_auto => (APP_CONFIG['smtp_enable_starttls_auto']),
  :port => APP_CONFIG['smtp_port'] || 25
}