class AddOgranizationIdToOrganizationalRole < ActiveRecord::Migration
  def up
    add_column :organizational_roles, :organization_id, :integer
    
    OrganizationalRole.delete_all
    contact = Role.find_by_i18n('contact').id
    admin = Role.find_by_i18n('admin').id
    leader = Role.find_by_i18n('leader').id
    %w[contact admin leader].each do |role|
      OrganizationMembership.where(role: role).each do |om|
        OrganizationalRole.create(role_id: eval(role), person_id: om.person_id, organization_id: om.organization_id)
      end
    end
    remove_column :organization_memberships, :role
  end
  
  def down
    add_column :organization_memberships, :role, :string
    remove_column :organizational_roles, :organization_id
  end
end
