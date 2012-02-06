class CreateSavedContactSearches < ActiveRecord::Migration
  def change
    create_table :saved_contact_searches do |t|
      t.string :name
      t.string :full_path
      t.belongs_to :user

      t.timestamps
    end
    add_index :saved_contact_searches, :user_id
  end
end
