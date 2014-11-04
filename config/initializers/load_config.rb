unless defined?(APP_CONFIG)
  require 'base62'
  require Rails.root.join('lib','active_record').to_s
  APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
  APP_CONFIG['public_host'] ||= 'mhub.cc'
  APP_CONFIG['public_port'] ||= 80
  APP_CONFIG['site_title'] = 'MissionHub'

  case Rails.env
  when "development"
     APP_CONFIG['site_domain'] = "local.missionhub.com:7888"
  when "staging"
     APP_CONFIG['site_domain'] = "stage.missionhub.com"
  when "production"
     APP_CONFIG['site_domain'] = "www.missionhub.com"
  end
end