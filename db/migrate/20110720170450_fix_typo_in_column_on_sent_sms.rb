class FixTypoInColumnOnSentSms < ActiveRecord::Migration
  def change
    rename_column :sent_sms, :recieved_sms_id, :received_sms_id
  end
end