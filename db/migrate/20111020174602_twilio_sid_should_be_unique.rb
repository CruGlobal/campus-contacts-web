class TwilioSidShouldBeUnique < ActiveRecord::Migration
  def up
    add_index :sent_sms, :twilio_sid, :unique => true
    add_index :received_sms, :twilio_sid, :unique => true
  end

  def down
    remove_index :sent_sms, :twilio_sid
    remove_index :received_sms, :twilio_sid
  end
end