
require Rails.root.join('config', 'initializers', 'redis')

Rails.application.config.cache_store = :redis_store, {
  host: Redis.current.client.host,
  port: Redis.current.client.port,
  db: 1,
  namespace: "missionhub:cache:",
  expires_in: 1.day
}
