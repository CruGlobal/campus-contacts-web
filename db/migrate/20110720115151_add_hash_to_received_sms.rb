class AddHashToReceivedSms < ActiveRecord::Migration
  def change
    add_column :received_sms, :hash, :string
  end
end
