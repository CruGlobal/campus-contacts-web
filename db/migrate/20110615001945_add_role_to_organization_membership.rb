class AddRoleToOrganizationMembership < ActiveRecord::Migration
  def self.up
    add_column :organization_memberships, :role, :string
    OrganizationMembership.update_all("role = 'admin'", 'leader = 1')
    OrganizationMembership.update_all("role = 'contact'", 'leader = 0')
    remove_column :organization_memberships, :leader
  end
  
  def self.down
    add_column :organization_memberships, :role, :boolean, :default => 0
    OrganizationMembership.update_all('leader = 1', "role = 'admin'")
    OrganizationMembership.update_all('leader = 0', "role = 'contact'")
    remove_column :organization_memberships, :role
  end
end
