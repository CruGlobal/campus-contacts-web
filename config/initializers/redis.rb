case
when Rails.env.production?
  $redis = Redis.new(:host => 'redis', :port => 6379)
else
  $redis = Redis.new(:host => '127.0.0.1', :port => 6379)
  $redis.flushdb if Rails.env = "test"
end

