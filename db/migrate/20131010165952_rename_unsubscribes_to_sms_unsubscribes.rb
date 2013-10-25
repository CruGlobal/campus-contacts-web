class RenameUnsubscribesToSmsUnsubscribes < ActiveRecord::Migration
  def up
    remove_column :unsubscribes, :phone_number_id
    add_column :unsubscribes, :phone_number, :string, after: "id"
    rename_table :unsubscribes, :sms_unsubscribes
  end

  def down
    rename_table :sms_unsubscribes, :unsubscribes
  end
end
