class AddIndexesToMhFriend < ActiveRecord::Migration
  def change
    add_index :mh_friends, [:person_id, :uid], :name => "person_uid", :unique => true
  end
end