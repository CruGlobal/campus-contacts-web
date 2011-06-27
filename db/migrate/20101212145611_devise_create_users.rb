class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    add_column :simplesecuritymanager_user, :email, :string
    add_column :simplesecuritymanager_user, :encrypted_password, :string
    add_column :simplesecuritymanager_user, :remember_created_at, :datetime
    add_column :simplesecuritymanager_user, :sign_in_count, :integer, default: 0
    add_column :simplesecuritymanager_user, :current_sign_in_at, :datetime
    add_column :simplesecuritymanager_user, :current_sign_in_ip, :string
    add_column :simplesecuritymanager_user, :last_sign_in_ip, :string
    add_column :simplesecuritymanager_user, :created_at, :datetime
    add_column :simplesecuritymanager_user, :updated_at, :datetime

    add_index :simplesecuritymanager_user, :email,                unique: true
  end

  def self.down
    remove_column :simplesecuritymanager_user, :updated_at
    remove_column :simplesecuritymanager_user, :created_at
    remove_column :simplesecuritymanager_user, :last_sign_in_ip
    remove_column :simplesecuritymanager_user, :current_sign_in_ip
    remove_column :simplesecuritymanager_user, :current_sign_in_at
    remove_column :simplesecuritymanager_user, :sign_in_count
    remove_column :simplesecuritymanager_user, :remember_created_at
    remove_column :simplesecuritymanager_user, :encrypted_password
    remove_column :simplesecuritymanager_user, :email
    drop_table :simplesecuritymanager_user
  end
end