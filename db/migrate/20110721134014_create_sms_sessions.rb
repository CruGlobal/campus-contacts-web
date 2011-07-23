class CreateSmsSessions < ActiveRecord::Migration
  def change
    create_table :sms_sessions do |t|
      t.string :phone_number
      t.integer :person_id
      t.integer :sms_keyword_id
      t.boolean :interactive, default: false, null: false

      t.timestamps
    end
    add_index :sms_sessions, [:phone_number, :updated_at], :name => "session"
    remove_column :received_sms, :interactive
    add_column :received_sms, :sms_session_id, :integer
  end
end