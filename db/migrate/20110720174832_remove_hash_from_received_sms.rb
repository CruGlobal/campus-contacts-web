class RemoveHashFromReceivedSms < ActiveRecord::Migration
  def up
    remove_column :received_sms, :hash
    remove_column :received_sms, :followed_up
    remove_column :received_sms, :assigned_to_id
    remove_column :received_sms, :response_count
  end

  def down
    add_column :received_sms, :hash, :string
    add_column :received_sms, :followed_up, :boolean
    add_column :received_sms, :assigned_to_id, :integer
    add_column :received_sms, :response_count, :integer
  end
end
