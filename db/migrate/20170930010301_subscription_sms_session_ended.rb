class SubscriptionSmsSessionEnded < ActiveRecord::Migration
  def change
    add_column :subscription_sms_sessions, :ended, :boolean, default: false, null: false
  end
end
