class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :address1
      t.string :address2
      t.string :address3
      t.string :address4
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :address_type
      t.integer :person_id
      t.datetime :start_date
      t.datetime :end_date
      t.string :dorm
      t.string :room

      t.timestamps
    end
  end
end
