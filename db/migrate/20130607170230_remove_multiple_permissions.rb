class Person < ActiveRecord::Base
end
class Permission < ActiveRecord::Base
end
class OrganizationalPermission < ActiveRecord::Base
end
class RemoveMultiplePermissions < ActiveRecord::Migration
  def up
    admin_id = Permission::ADMIN_ID
    user_id = Permission::USER_ID
    contact_id = Permission::NO_PERMISSIONS_ID
    OrganizationalPermission.where(person_id: nil).destroy_all
    OrganizationalPermission.select("person_id AS PERSON_ID, COUNT(person_id) AS PERMISSION_COUNT").group("person_id HAVING PERMISSION_COUNT > 1").each do |person_obj|
      if person_obj['PERSON_ID'].nil?
        next
      end
      person = Person.where(id: person_obj['PERSON_ID']).try(:first)
      if person.present?
        organizational_permissions = OrganizationalPermission.where("person_id = ?", person.id)
        puts "Person##{person.id} - #{organizational_permissions.count} permission#{'s' if organizational_permissions.count > 1}"

        if organizational_permissions.count > 1
          organizational_permissions.select('DISTINCT(organization_id)').each do |org_obj|
            org_id = org_obj['organization_id'].inspect
            
            org_perms = organizational_permissions.where(organization_id: org_id)

            puts "Organization##{org_id} - #{org_perms.count} permission#{'s' if org_perms.count > 1}"
            if org_perms.count > 1
              puts ">> Cleaning permissions - #{org_perms.collect(&:permission_id)}"
              
              admin = org_perms.where(permission_id: admin_id).try(:first)
              if admin.present?
                puts ">> Clear other than ADMIN - #{admin_id}"
                org_perms.where("id != ?", admin.id).destroy_all
              end
              
              user = org_perms.where(permission_id: user_id).try(:first)
              if user.present?
                puts ">> Clear other than USER - #{user_id}"
                org_perms.where("id != ?", user.id).destroy_all
              end
              
              contact = org_perms.where(permission_id: contact_id).try(:first)
              if contact.present?
                puts ">> Clear other than NO_PERMISSIONS - #{contact_id}"
                org_perms.where("id != ?", contact_id.id).destroy_all
              end
              
              puts ">> Remaining permissions - #{organizational_permissions.where(organization_id: org_id).collect(&:permission_id)}"
            end
          end
        end
      else 
        puts "Missing Person##{person_obj['PERSON_ID']} - Permissions deleted"
        # Destroy permissions of missing person
        OrganizationalPermission.where(person_id: person_obj['PERSON_ID']).destroy_all
      end
      puts ""
      puts ""
    end
  end

  def down
  end
end
