class AddIndexesToReceivedSms < ActiveRecord::Migration
  def change
    add_index :received_sms, [:city, :state, :zip, :country]
  end
end
