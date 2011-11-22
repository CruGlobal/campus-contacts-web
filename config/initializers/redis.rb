if Rails.env.production?
  $redis = Redis.new(:host => '10.10.11.166', :port => 6379)
else
  $redis = Redis.new(:host => '127.0.0.1', :port => 6379)
end