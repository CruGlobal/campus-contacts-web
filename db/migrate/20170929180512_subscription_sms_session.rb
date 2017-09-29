class SubscriptionSmsSession < ActiveRecord::Migration
  def change
    create_table :subscription_sms_sessions do |t|
      t.string :phone_number
      t.integer :person_id
      t.boolean :interactive, default: false, null: false

      t.timestamps
    end
  end
end
