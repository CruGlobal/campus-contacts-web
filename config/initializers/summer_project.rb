require 'summer_project'

SummerProject.configure do |config|
  config.access_token = APP_CONFIG['summer_project_token']
  config.base_url = APP_CONFIG['summer_project_url']
end