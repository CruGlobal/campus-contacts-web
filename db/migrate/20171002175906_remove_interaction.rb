class RemoveInteraction < ActiveRecord::Migration
  def change
    remove_column :subscription_sms_sessions, :interactive, :boolean, default: false, null: false
  end
end
