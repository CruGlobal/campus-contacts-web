class CreateAuthentications < ActiveRecord::Migration
  def self.up
    create_table :authentications do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.string :token

      t.timestamps
    end
    add_index :authentications, [:user_id, :provider, :uid], :unique => true
    add_index :authentications, [:provider, :uid], :unique => true
  end

  def self.down
    remove_index :authentications, :column => [:user_id, :provider, :uid]
    remove_index :authentications, :column => [:provider, :uid]
    drop_table :authentications
  end
end