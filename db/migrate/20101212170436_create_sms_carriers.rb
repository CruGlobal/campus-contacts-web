class CreateSmsCarriers < ActiveRecord::Migration
  def self.up
    create_table :sms_carriers do |t|
      t.string :name
      t.string :moonshado_name
      t.string :email
      t.integer :recieved, :default => 0
      t.integer :sent_emails, :default => 0
      t.integer :bounced_emails, :default => 0
      t.integer :sent_sms, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :sms_carriers
  end
end
