require 'redis'
require 'redis/namespace'

Redis.current = Redis.new(host: ENV['REDIS_PORT_6379_TCP_ADDR'])
