class Organization < ActiveRecord::Base
end
class OrganizationalRole < ActiveRecord::Base
end
class OrganizationMembership < ActiveRecord::Base
end

class AddOgranizationIdToOrganizationalRole < ActiveRecord::Migration
  def up
    add_column :organizational_roles, :organization_id, :integer

    OrganizationalRole.delete_all
    contact = Role.where(i18n: 'contact').first.try(:id)
    admin = Role.where(i18n: 'admin').first.try(:id)
    leader = Role.where(i18n: 'leader').first.try(:id)
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
