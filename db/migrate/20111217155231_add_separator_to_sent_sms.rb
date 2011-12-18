class AddSeparatorToSentSms < ActiveRecord::Migration
  def change
    add_column :sent_sms, :separator, :string
  end
end
