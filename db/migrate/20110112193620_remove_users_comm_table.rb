class RemoveUsersCommTable < ActiveRecord::Migration
  def self.up
      drop_table :user_community_joins
  end

  def self.down
    create_table :user_community_joins do |t|
      t.integer :user_id
      t.integer :community_id

      t.timestamps
    end
  end
end
