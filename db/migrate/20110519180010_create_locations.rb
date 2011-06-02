class CreateLocations < ActiveRecord::Migration
  def change
    create_table :mh_location do |t|
      t.string :location_id
      t.string :name
      t.string :provider
      t.integer :person_id

      t.timestamps
    end
  end
end
