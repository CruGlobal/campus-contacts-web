class CreateCommunityMemberships < ActiveRecord::Migration
  def self.up
    create_table :community_memberships do |t|
      t.integer :community_id
      t.integer :person_id
      t.timestamps
    end
  end

  def self.down
    drop_table :community_memberships
  end
end
