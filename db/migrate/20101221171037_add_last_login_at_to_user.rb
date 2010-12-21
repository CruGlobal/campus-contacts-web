class AddLastLoginAtToUser < ActiveRecord::Migration
  def self.up
    add_column :simplesecuritymanager_user, :last_sign_in_at, :datetime
  end

  def self.down
    remove_column :simplesecuritymanager_user, :last_sign_in_at
  end
end
