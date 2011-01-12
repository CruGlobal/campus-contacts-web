class CreateUserCommunityJoins < ActiveRecord::Migration
  def self.up
    create_table :user_community_joins do |t|
      t.integer :user_id
      t.integer :community_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_community_joins
  end
end
