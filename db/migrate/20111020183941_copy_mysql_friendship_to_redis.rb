class CopyMysqlFriendshipToRedis < ActiveRecord::Migration
  def up
    Friend.all.each do |friend|
      friend.follow!(friend.person) if 'facebook' == friend.provider
    end 
  end

  def down
  end
end
