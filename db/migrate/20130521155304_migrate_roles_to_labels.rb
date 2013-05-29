class Label < ActiveRecord::Base
end
class Role < ActiveRecord::Base
end
class OrganizationalRole < ActiveRecord::Base
end
class OrganizationalLabel < ActiveRecord::Base
end
class MigrateRolesToLabels < ActiveRecord::Migration
  def up
    Label.delete_all
    Label.create(name: 'Involved', i18n: 'involved', organization_id: 0)
    Label.create(name: 'Engaged Disciple', i18n: 'engaged_disciple', organization_id: 0)
    Label.create(name: 'Leader', i18n: 'leader', organization_id: 0)
    OrganizationalLabel.delete_all
    Role.where('name IS NULL').destroy_all
    Label.where('name IS NULL').destroy_all
    
    Role.where("(i18n IS NOT NULL AND i18n NOT IN (?)) OR organization_id > 0 OR organization_id IS NULL", ['admin','contact','leader']).each do |role|
      if role.organization_id.present?
        if role.i18n == 'involved'
          label = Label.find_by_i18n_and_organization_id('involved',0)
        else
          label = Label.create(
            name: role.name, 
            organization_id: role.organization_id,
            i18n: role.i18n,
            created_at: role.created_at,
            updated_at: role.updated_at
          )
        end
        puts ">>  Converting #{role.name} role to label"
        role.organizational_roles.each do |org_role|
          OrganizationalLabel.create(
            person_id: org_role.person_id,
            label_id: label.id,
            organization_id: org_role.organization_id,
            start_date: org_role.start_date,
            added_by_id: org_role.added_by_id,
            removed_date: org_role.archive_date,
            created_at: org_role.created_at,
            updated_at: org_role.updated_at
          )
        end
        role.organizational_roles.destroy_all
      end
      role.destroy
    end
    # Data Cleanup
    puts ">>  Cleaning data"
    remaining_role_ids = Role.where("name IN (?)", ['Admin','Contact','Leader']).collect(&:id)
    OrganizationalRole.where("role_id NOT IN (?)",remaining_role_ids).destroy_all
    OrganizationalRole.where('role_id IS NULL').destroy_all
  end

  def down
  end
end
