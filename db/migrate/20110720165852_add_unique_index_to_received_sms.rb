class AddUniqueIndexToReceivedSms < ActiveRecord::Migration
  def change
    add_index :received_sms, [:phone_number, :message, :received_at], :unique => true
  end
end