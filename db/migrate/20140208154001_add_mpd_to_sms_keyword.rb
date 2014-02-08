class AddMpdToSmsKeyword < ActiveRecord::Migration
  def change
    add_column :sms_keywords, :mpd, :boolean, default: false, null: false
    add_column :sms_keywords, :mpd_phone_number, :string
  end
end
