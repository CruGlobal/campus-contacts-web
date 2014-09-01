class AddStatusToSentSms < ActiveRecord::Migration
  def change
    add_column :sent_sms, :status, :string, after: "sent_via", default: "queued"
    SentSms.update_all(status: "sent")
  end
end
