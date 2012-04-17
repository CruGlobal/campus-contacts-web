case
when Rails.env.production?
  $redis = Redis.new(:host => '10.10.11.166', :port => 6379)
when Rails.env.rackspace?
  $redis = Redis.new(:host => '10.179.150.27', :port => 6379)
else
  $redis = Redis.new(:host => '127.0.0.1', :port => 6379)
end
