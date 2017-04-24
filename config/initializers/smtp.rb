ActionMailer::Base.smtp_settings = {
  user_name: ENV.fetch('SMTP_USER_NAME'),
  password: ENV.fetch('SMTP_PASSWORD'),
  address: ENV.fetch('SMTP_ADDRESS'),
  authentication: ENV['SMTP_AUTHENTICATION'] || :none,
  enable_starttls_auto: ENV['SMTP_ENABLE_STARTTLS_AUTO'] || true,
  port: ENV['SMTP_PORT'] || 587
}
