class AddLeaderFlagToOrganizationMembership < ActiveRecord::Migration
  def change
    add_column :organization_memberships, :leader, :boolean, :default => false
  end
end
