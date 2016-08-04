if (ENV['APP_DOMAIN'] == 'stage.missionhub.com' && ENV['MINI_PROFILER']) || Rails.env.development?
  require 'rack-mini-profiler'
  # initialization is skipped so trigger it
  Rack::MiniProfilerRails.initialize!(Rails.application)
  Rack::MiniProfiler.config.start_hidden = true
end
