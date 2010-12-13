class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.string :email
      t.string :phone_number
      t.date   :birthday

      t.timestamps
    end
    
    add_column :users, :person_id, :integer
  end

  def self.down
    remove_column :users, :person_id
    drop_table :people
  end
end