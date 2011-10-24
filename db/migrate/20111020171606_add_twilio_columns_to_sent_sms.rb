class AddTwilioColumnsToSentSms < ActiveRecord::Migration
  def change
    change_table :sent_sms, :bulk => true do |t|
      t.string :twilio_sid
      t.string :twilio_uri
    end
    
    change_table :received_sms, :bulk => true do |t|
      t.string :state
      t.string :city
      t.string :zip
      t.string :twilio_sid
    end
  end
end
