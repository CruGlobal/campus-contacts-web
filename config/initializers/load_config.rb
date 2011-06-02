unless defined?(APP_CONFIG)
  require 'base62'
  require Rails.root.join('lib','active_record').to_s
  APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
  APP_CONFIG['site_title'] = 'MissionHub'
end