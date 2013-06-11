class AddMobileTokenToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :mobile_token, :string
    add_index :authentications, [:provider, :mobile_token], name: 'provider_token'
  end
end
