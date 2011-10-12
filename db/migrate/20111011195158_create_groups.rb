class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.text :location
      t.string :meets
      t.integer :meeting_day
      t.integer :start_time
      t.integer :end_time
      t.integer :organization_id

      t.timestamps
    end
  end
end
