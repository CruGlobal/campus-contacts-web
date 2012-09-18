class RemoveUniqueIndexOnEmail < ActiveRecord::Migration
  def up
    remove_index :email_addresses, [:person_id, :email]
    add_index :email_addresses, :email, unique: false, name: 'email'
    add_index :email_addresses, :person_id, unique: false, name: 'person_id'
  end

  def down
    remove_index :email_addresses, name: 'email'
    remove_index :email_addresses, name: 'person_id'
    add_index :email_addresses, [:person_id, :email], unique: true
  end
end
