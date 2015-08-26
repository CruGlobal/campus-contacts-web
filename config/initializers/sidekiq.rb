
require Rails.root.join('config', 'initializers', 'redis').to_s

redis_settings = { url: Redis.current.client.id,
                   namespace: "sidekiq:#{Rails.env}"}

Sidekiq.configure_client do |config|
  config.redis = redis_settings
end

if Sidekiq::Client.method_defined? :reliable_push!
  Sidekiq::Client.reliable_push!
end

Sidekiq.configure_server do |config|
  config.reliable_fetch!
  config.reliable_scheduler!
  config.redis = redis_settings
  config.failures_default_mode = :exhausted
end

Sidekiq.default_worker_options = { backtrace: true }
