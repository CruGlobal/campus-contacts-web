class AddTerminatedToSmsSession < ActiveRecord::Migration
  def change
    add_column :sms_sessions, :terminated, :boolean, null: false, default: false
  end
end
