class AddUniqueIndexToPhoneNumber < ActiveRecord::Migration
  def change
    add_index :phone_numbers, [:person_id, :number], :unique => true
    add_index :email_addresses, [:person_id, :email], :unique => true
  end
end