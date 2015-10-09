class AddIndexMessageIdToSentSms < ActiveRecord::Migration
  def change
    add_index :sent_sms, [:message_id], name: "index_sent_sms_on_message_id", unique: false
    execute "ALTER TABLE sent_sms MODIFY message TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
  end
end
