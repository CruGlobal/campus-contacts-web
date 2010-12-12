class CreateSentSms < ActiveRecord::Migration
  def self.up
    create_table :sent_sms do |t|
      t.string :message
      t.integer :recipient
      t.text :reports
      t.string :moonshado_claimcheck
      t.string :sent_via
      t.integer :recieved_sms_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sent_sms
  end
end
