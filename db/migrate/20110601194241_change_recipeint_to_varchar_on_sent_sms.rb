class ChangeRecipeintToVarcharOnSentSms < ActiveRecord::Migration
  def up
    change_column :sent_sms, :recipient, :string
    add_column :received_sms, :interactive, :boolean, :default => false
    add_column :received_sms, :sms_keyword_id, :integer
  end

  def down
    change_column :sent_sms, :recipient, :integer
    remove_column :received_sms, :interactive
    # remove_column :received_sms, :sms_keyword_id
  end
end