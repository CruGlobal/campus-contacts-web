
require 'redis'
require 'redis/namespace'

redis_config = YAML.load(ERB.new(File.read(Rails.root.join('config', 'redis.yml').to_s)).result)
host, port = redis_config[Rails.env].split(':')
Redis.current = Redis::Namespace.new("infobase:#{Rails.env}", redis: Redis.new(host: host, port: port))
