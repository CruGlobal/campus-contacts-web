class CreateKeywordRequests < ActiveRecord::Migration
  def self.up
    create_table :keyword_requests do |t|
      t.text :message
      t.string :keyword
      t.integer :user_id
      t.integer :community_id

      t.timestamps
    end
  end

  def self.down
    drop_table :keyword_requests
  end
end
