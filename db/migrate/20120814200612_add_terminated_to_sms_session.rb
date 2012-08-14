class AddTerminatedToSmsSession < ActiveRecord::Migration
  def change
    add_column :sms_sessions, :ended, :boolean, null: false, default: false
  end
end
