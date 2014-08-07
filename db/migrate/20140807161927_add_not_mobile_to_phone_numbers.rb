class AddNotMobileToPhoneNumbers < ActiveRecord::Migration
  def change
    add_column :phone_numbers, :not_mobile, :boolean, after: 'primary', default: false
  end
end
