class CreateNewPeople < ActiveRecord::Migration
  def change
    create_table :mh_new_people do |t|
      t.integer :person_id
      t.integer :organization_id
      t.boolean :notified, default: false

      t.timestamps
    end
  end
end
