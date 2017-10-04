class SubscriptionChoices < ActiveRecord::Migration
  def change
    create_table :subscription_choices do |t|
      t.integer :value
      t.integer :subscription_sms_session_id
      t.integer :organization_id
    end
  end
end
