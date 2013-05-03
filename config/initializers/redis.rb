redis_config = YAML.load_file(rails_root + '/config/redis.yml')

$redis = Redis.new(:host => resque_config[rails_env], :port => 6379)

$redis.flushdb if Rails.env = "test"
