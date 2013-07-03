redis_config = YAML.load_file(Rails.root.join('config','redis.yml'))
server, port = redis_config[Rails.env].split(':')

$redis = Redis.new(:host => server, :port => port)
