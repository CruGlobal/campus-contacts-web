class AddRoleToOrganizationMembership < ActiveRecord::Migration
  def self.up
    add_column :organization_memberships, :role, :string
    remove_column :organization_memberships, :leader
  end
  
  def self.down
    add_column :organization_memberships, :role, :boolean, default: 0
    remove_column :organization_memberships, :role
  end
end
