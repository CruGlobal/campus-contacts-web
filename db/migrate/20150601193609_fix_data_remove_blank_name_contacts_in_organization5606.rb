class FixDataRemoveBlankNameContactsInOrganization5606 < ActiveRecord::Migration
  def up
    # Organization that has blank name contacts
    org_id = 5606

    org = Organization.where(id: org_id).first
    if org.present?
      blank_name_contacts = org.all_people.where("(people.last_name IS NULL AND people.first_name IS NULL) OR (people.last_name = '' AND people.first_name = '')")
      if blank_name_contacts.present?
        blank_name_contacts.each do |contact|
          permission = contact.all_organizational_permissions.where(organization_id: org.id).first
          permission.destroy if permission.present?
        end
      else
        puts "There's no contacts that has blank name."
      end

      # Removing all organizational permissions that person data does not exist in the database
      org_permissions = org.organizational_permissions
      if org_permissions.present?
        org_permissions.each do |org_permission|
          org_permission.destroy unless org_permission.person.present?
        end
      end
    else
      puts "Can't find the organization."
    end
  end

  def down
  end
end
