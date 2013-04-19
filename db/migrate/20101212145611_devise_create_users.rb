class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :email, :string
    add_column :users, :encrypted_password, :string
    add_column :users, :remember_created_at, :datetime
    add_column :users, :sign_in_count, :integer, default: 0
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string
    add_column :users, :created_at, :datetime
    add_column :users, :updated_at, :datetime

    add_index :users, :email,                unique: true
  end

  def self.down
    remove_column :users, :updated_at
    remove_column :users, :created_at
    remove_column :users, :last_sign_in_ip
    remove_column :users, :current_sign_in_ip
    remove_column :users, :current_sign_in_at
    remove_column :users, :sign_in_count
    remove_column :users, :remember_created_at
    remove_column :users, :encrypted_password
    remove_column :users, :email
    drop_table :users
  end
end