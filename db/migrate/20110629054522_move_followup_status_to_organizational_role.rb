class MoveFollowupStatusToOrganizationalRole < ActiveRecord::Migration
  def up
    add_column :organizational_roles, :followup_status, :string
    remove_column :organization_memberships, :followup_status
  end

  def down
    remove_column :organizational_roles, :followup_status
    add_column :organization_memberships, :followup_status, :string
  end
end