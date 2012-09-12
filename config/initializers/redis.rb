case
when Rails.env.production?
  $redis = Redis.new(:host => '10.178.202.203', :port => 6379)
else
  $redis = Redis.new(:host => '127.0.0.1', :port => 6379)
end
