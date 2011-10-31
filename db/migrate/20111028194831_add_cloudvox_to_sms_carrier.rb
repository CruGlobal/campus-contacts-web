class AddCloudvoxToSmsCarrier < ActiveRecord::Migration
  def change
    add_column :sms_carriers, :cloudvox_name, :string
  end
end
