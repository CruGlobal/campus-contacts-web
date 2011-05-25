class CreateFriends < ActiveRecord::Migration
  def change
    create_table :mh_friend do |t|
      t.string :name
      t.string :uid
      t.string :provider
      t.integer :person_id

      t.timestamps
    end
  end
end
