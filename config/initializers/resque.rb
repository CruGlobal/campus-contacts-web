require 'resque/server'

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')
Resque.redis = resque_config[rails_env]

if APP_CONFIG['resque_username']
  Resque::Server.use Rack::Auth::Basic do |username, password|
    username == APP_CONFIG['resque_username']
    password == APP_CONFIG['resque_password']
  end
end

# RESQUE JOB TYPES

class RetrieveFBFriends
  @queue = :fb
  def self.perform(user_id, fb_uid, access_token)
  #  user = User.find_by_user_ID(user_id)
    @type = "friends"
    @fb_uid = fb_uid
    @access_token = access_token
    @response_hash = MiniFB.get(@access_token.to_s, @fb_uid, type: @type)
    open('fbfriends.log', 'a') { |f|
      f.puts Time.now.to_s
      f.puts @response_hash.to_json
      f.puts "\n\n"
    }
  end
end

    