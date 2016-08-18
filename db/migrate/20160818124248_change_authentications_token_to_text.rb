class ChangeAuthenticationsTokenToText < ActiveRecord::Migration
  def change
    change_column :authentications, :token, :text
  end
end
