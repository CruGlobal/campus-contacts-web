ActionMailer::Base.smtp_settings = {
  :user_name => ENV.fetch('SMTP_USER_NAME'),
  :password => ENV.fetch('SMTP_PASSWORD'),
  :address => ENV.fetch('SMTP_ADDRESS'),
  :authentication => (ENV.fetch('SMTP_AUTHENTICATION') || :none),
  :enable_starttls_auto => ENV.fetch('SMTP_ENABLE_STARTTLS_AUTO'),
  :port => ENV.fetch('SMTP_PORT') || 25
}