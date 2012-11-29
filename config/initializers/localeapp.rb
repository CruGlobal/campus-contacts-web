if defined?(Rails) && Rails.env.development?
  Localeapp.configure do |config|
    config.sending_environments = []
  end
end
