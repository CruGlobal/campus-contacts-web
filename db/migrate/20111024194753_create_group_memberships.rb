class CreateGroupMemberships < ActiveRecord::Migration
  def change
    create_table :group_memberships do |t|
      t.belongs_to :group
      t.belongs_to :person
      t.string :role, :default => 'member'
      t.boolean :requested, :default => false

      t.timestamps
    end
    add_index :group_memberships, :group_id
    add_index :group_memberships, :person_id
    
    rename_table :groups, :mh_groups
  end
  
end