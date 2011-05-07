class GetRidOfKeywordRequests < ActiveRecord::Migration
  def self.up
    drop_table :keyword_requests
    drop_table :sms_keywords
    create_table :sms_keywords do |t|
      t.string :name
      t.integer :activity_id
      t.integer :community_id

      t.timestamps
    end
  end

  def self.down
    create_table :keyword_requests do |t|
      t.text :explanation
      t.string :keyword
      t.integer :user_id
      t.string  :chartfield

      t.timestamps
    end
  end
end