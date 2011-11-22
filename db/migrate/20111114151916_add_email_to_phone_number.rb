class AddEmailToPhoneNumber < ActiveRecord::Migration
  def change
    add_column :phone_numbers, :email_updated_at, :datetime
    add_column :sms_carriers, :data247_name, :string
    remove_column :phone_numbers, :carrier_name
  end
end