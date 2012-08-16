class RemoveUniqueIndexOnEmail < ActiveRecord::Migration
  def up
    remove_index :email_addresses, name: 'email'
    add_index :email_addresses, :email
  end

  def down
    remove_index :email_addresses, 'email'
    add_index :email_addresses, :email, unique: true
  end
end
