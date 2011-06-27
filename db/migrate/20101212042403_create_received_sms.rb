class CreateReceivedSms < ActiveRecord::Migration
  def self.up
    create_table :received_sms do |t|
      t.string :phone_number
      t.string :carrier
      t.string :shortcode
      t.string :message
      t.string :country
      t.string :person_id
      t.datetime :received_at
      t.boolean :followed_up, default: false
      t.integer :assigned_to_id
      t.integer :response_count, default: 0

      t.timestamps
    end
  end

  def self.down
    drop_table :received_sms
  end
end
