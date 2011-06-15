class AddFollowupStatusToOrganizationMembership < ActiveRecord::Migration
  def self.up
    change_table :organization_memberships do |t|
      t.column :followup_status, "ENUM('uncontacted','attempted_contact','contacted','do_not_contact','completed')"
    end
    add_index :organization_memberships, :followup_status
  end
  
  def self.down
    remove_column :organization_memberships, :followup_status
  end
end