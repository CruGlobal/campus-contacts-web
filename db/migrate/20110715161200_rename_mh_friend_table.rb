class RenameMhFriendTable < ActiveRecord::Migration
  def change
    rename_table :mh_friend, :mh_friends
  end
end