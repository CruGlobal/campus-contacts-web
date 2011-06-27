class CreateOrganizationMemberships < ActiveRecord::Migration
  def self.up
    create_table :organization_memberships do |t|
      t.integer :organization_id
      t.integer :person_id
      t.boolean :primary, default: 0
      t.boolean :validated, default: 0

      t.timestamps
    end
    
    add_index :organization_memberships, [:organization_id, :person_id], unique: true
  end

  def self.down
    drop_table :organization_memberships
  end
end