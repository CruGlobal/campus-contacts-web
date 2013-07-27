class Organization < ActiveRecord::Base
end
class OrganizationalLabel < ActiveRecord::Base
end
class OrganizationalPermission < ActiveRecord::Base
end
class Person < ActiveRecord::Base
end
class Permission < ActiveRecord::Base
end
class GenerateOrganizationalPermissions < ActiveRecord::Migration
  def up

    Organization.order('id').each do |org|
      member_people_ids = OrganizationalPermission.where("organization_id = ?", org.id).collect(&:person_id).uniq
      non_member_labeled_people_ids = OrganizationalLabel.where("organization_id = ? AND person_id NOT IN(?)", org.id, member_people_ids).collect(&:person_id).uniq

      if non_member_labeled_people_ids.count > 0
        puts "Organization##{org.id} - #{non_member_labeled_people_ids.count} missing permission#{'s' if non_member_labeled_people_ids.count > 1}"

        non_member_labeled_people_ids.each do |person_id|
          person = Person.where(id: person_id).try(:first)
          if person.present?
            puts ">> Create role for Person##{person_id}"
            labels = OrganizationalLabel.where(organization_id: org.id, person_id: person_id)
            OrganizationalPermission.create(organization_id: org.id, person_id: person_id, permission_id: 2, start_date: labels.first.created_at)
          else
            puts ">> Person##{person_id} not found"
            OrganizationalLabel.where(organization_id: org.id, person_id: person_id).destroy_all
          end
        end
      end
    end
  end

  def down
  end
end
