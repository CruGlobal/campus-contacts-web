class CreateKeywordRequests < ActiveRecord::Migration
  def self.up
    create_table :keyword_requests do |t|
      t.text :explanation
      t.string :keyword
      t.integer :user_id
      t.string  :chartfield

      t.timestamps
    end
  end

  def self.down
    drop_table :keyword_requests
  end
end
