class AddMessageIdToSentSms < ActiveRecord::Migration
  def change
    add_column :sent_sms, :message_id, :integer, after: "id"
  end
end
