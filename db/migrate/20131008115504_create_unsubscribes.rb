class CreateUnsubscribes < ActiveRecord::Migration
  def change
    create_table :unsubscribes do |t|
      t.integer :phone_number_id
      t.integer :organization_id

      t.timestamps
    end
  end
end
