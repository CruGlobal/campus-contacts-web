class CreatePersonTransfers < ActiveRecord::Migration
  def change
    create_table :mh_person_transfers do |t|
      t.integer :person_id
      t.integer :old_organization_id
      t.integer :new_organization_id
      t.boolean :copy, :default => false
      t.boolean :notified, :default => false

      t.timestamps
    end
  end
end
