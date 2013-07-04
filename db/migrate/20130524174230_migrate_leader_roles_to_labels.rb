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
    Role.where('name IS NULL').destroy_all
    Label.where('name IS NULL').destroy_all
    new_leader = Label.find_or_create_by_name_and_i18n_and_organization_id('Leader', 'leader', 0)
    old_leader = Role.find_or_create_by_i18n_and_organization_id('leader', 0)
    if new_leader.present?
      OrganizationalRole.where(role_id: old_leader.id).each do |org_role|
        OrganizationalLabel.create(
          person_id: org_role.person_id,
          label_id: new_leader.id,
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
  end

  def down
  end
end
