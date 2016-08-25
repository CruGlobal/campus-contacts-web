class AddReplyToSentViaIndexToMessages < ActiveRecord::Migration
  def up
    execute 'create index index_messages_on_reply_to_sent_via on messages (`reply_to`, `sent_via`) lock=none;'
  end

  def down
    remove_index :messages, fields: [:reply_to, :sent_via], name: 'index_messages_on_reply_to_sent_via'
  end
end
