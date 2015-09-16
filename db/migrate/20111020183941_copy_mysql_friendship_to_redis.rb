class Friend < ActiveRecord::Base
end
class CopyMysqlFriendshipToRedis < ActiveRecord::Migration
  def up
    Friend.connection.select_all("select person_id, uid from mh_friends").each do |values|
      Redis.current.sadd("friend:#{values['uid']}:following", values['person_id'])
      Redis.current.sadd("friend:#{values['person_id']}:followers", values['uid'])
    end
    # Friend.all.each do |friend|
    #   friend.follow!(friend.person) if 'facebook' == friend.provider && friend.person
    # end 
  end

  def down
  end
end
