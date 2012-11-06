class DeprecateFriendsTable < ActiveRecord::Migration
  def up
    rename_table :friends, :friends_deprecated
  end

  def down
    rename_table :friends_deprecated, :friends
  end
end
