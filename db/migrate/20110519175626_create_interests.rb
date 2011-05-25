class CreateInterests < ActiveRecord::Migration
  def change
    create_table :mh_interest do |t|
      t.string :name
      t.string :interest_id
      t.string :provider
      t.string :category
      t.integer :person_id
      t.datetime :interest_created_time

      t.timestamps
    end
  end
end
