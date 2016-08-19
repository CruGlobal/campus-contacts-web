class AddPersonIdIndexToSmsSessions < ActiveRecord::Migration
  def change
    add_index :sms_sessions, :person_id
  end
end
