class Label < ActiveRecord::Base
end
class Role < ActiveRecord::Base
end
class OrganizationalRole < ActiveRecord::Base
end
class OrganizationalLabel < ActiveRecord::Base
end
class MigrateLeaderRolesToLabels < ActiveRecord::Migration
  def up
    leader_id = Label.leader.id
    OrganizationalRole.where(role_id: Role::LEADER_ID).each do |org_role|
      OrganizationalLabel.create(
        person_id: org_role.person_id,
        label_id: leader_id,
        organization_id: org_role.organization_id,
        start_date: org_role.start_date,
        added_by_id: org_role.added_by_id,
        removed_date: org_role.archive_date,
        created_at: org_role.created_at,
        updated_at: org_role.updated_at
      )
    end
    if leader_role = Role.find_by_i18n('leader')
      leader_role.update_attributes({name: 'MissionHub User', i18n: 'missionhub_user'})
    end
    Role.create(organization_id: 0, name: 'Archived', i18n: 'archived') unless archived_role = Role.find_by_i18n('archived')
  end

  def down
  end
end
