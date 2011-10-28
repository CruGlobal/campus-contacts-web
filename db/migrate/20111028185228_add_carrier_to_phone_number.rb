class AddCarrierToPhoneNumber < ActiveRecord::Migration
  def change
    add_column :phone_numbers, :carrier, :string
    add_column :phone_numbers, :txt_to_email, :string
  end
end
