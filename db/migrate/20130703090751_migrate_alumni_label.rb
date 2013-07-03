class Label < ActiveRecord::Base
end
class OrganizationalLabel < ActiveRecord::Base
end
class Person < ActiveRecord::Base
end
class MigrateAlumniLabel < ActiveRecord::Migration
  def up
    alumni_label = Label.find_by_i18n('alumni')
    if alumni_label.present?
      orgs_ids_with_alumni_label = OrganizationalLabel.where(label_id: alumni_label.id).collect(&:organization_id)
      orgs_with_alumni_label = Organization.where(id: orgs_ids_with_alumni_label)
      puts ">> Migrating Alumni Labels from #{orgs_with_alumni_label.count} Organizations"
      orgs_with_alumni_label.each do |org|
        puts ">> Processing Organization##{org.id}"
        new_label = Label.create(organization_id: org.id, name: "Alumni")

        ctr = 0
        alumni_labels = OrganizationalLabel.where(label_id: alumni_label.id, organization_id: org.id)
        alumni_labels.each do |org_label|
          new_org_label = OrganizationalLabel.new(org_label.attributes)
          new_org_label.label_id = new_label.id
          if new_org_label.save
            ctr += 1
            org_label.destroy
          end
        end
        puts ">>>> Migrated #{ctr} organizational labels"
      end
      alumni_label.destroy
      puts ">>>> Migration complete! Alumni default label is now deleted."
    else
      raise "Alumni label was already deleted!"
    end
  end

  def down
  end
end
