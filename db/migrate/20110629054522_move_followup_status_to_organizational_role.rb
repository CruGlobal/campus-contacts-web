class MoveFollowupStatusToOrganizationalRole < ActiveRecord::Migration
  def up
    add_column :organizational_roles, :followup_status, :string
    contact_role_id = Role.contact.id
    OrganizationMembership.where("followup_status is not null").each do |om|
      org_role = OrganizationalRole.where(person_id: om.person_id, organization_id: om.organization_id, role_id: contact_role_id).first
      org_role.update_attribute(:followup_status, om.followup_status) if org_role
    end
    remove_column :organization_memberships, :followup_status
  end

  def down
    remove_column :organizational_roles, :followup_status
    add_column :organization_memberships, :followup_status, :string
  end
end