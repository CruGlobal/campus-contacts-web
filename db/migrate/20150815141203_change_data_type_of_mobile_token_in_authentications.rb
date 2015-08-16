class ChangeDataTypeOfMobileTokenInAuthentications < ActiveRecord::Migration
  def change
    remove_index :authentications, name: :provider_token
    add_index :authentications, :provider, name: "provider_token"
    change_column :authentications, :mobile_token, :text
  end
end
