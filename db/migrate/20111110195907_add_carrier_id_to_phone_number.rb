class AddCarrierIdToPhoneNumber < ActiveRecord::Migration
  def change
    add_column :phone_numbers, :carrier_id, :integer
    rename_column :phone_numbers, :carrier, :carrier_name
    add_index :phone_numbers, :carrier_id
  end
end