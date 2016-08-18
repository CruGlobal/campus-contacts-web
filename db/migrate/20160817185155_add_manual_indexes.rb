class AddManualIndexes < ActiveRecord::Migration
  def up
    execute 'create index index_messages_on_to_sent_created_at on messages (`to`, `sent`, `created_at`) lock=none;'
    execute 'create index index_sent_sms_on_received_sms_id_id on sent_sms (`received_sms_id`) lock=none;'
  end

  def down
    remove_index :messages, fields: [:to, :sent, :created_at], name: 'index_messages_on_to_sent_created_at'
    remove_index :sent_sms, fields: [:received_sms_id], name: 'index_sent_sms_on_received_sms_id_id'
  end
end
