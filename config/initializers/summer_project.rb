require 'summer_project'

SummerProject.configure do |config|
  config.access_token = ENV.fetch('SUMMER_PROJECT_TOKEN')
  config.base_url = ENV.fetch('SUMMER_PROJECT_URL')
end