class MergeDuplicateContactsInOrganization10033 < ActiveRecord::Migration
  def up
    # Organization that has duplicate contacts by name
    org_id = 10033

    org = Organization.where(id: org_id).first
    if org.present?
      duplicate_contacts = org.people
        .group("CONCAT(people.first_name,' ', people.last_name)")
        .having("COUNT(CONCAT(people.first_name,' ', people.last_name)) > 1")
      if duplicate_contacts.present?
        puts "~ Duplicate records were found ~"
        duplicate_contacts.each do |duplicate_contact|
          records = org.people.where("
            people.first_name = ? AND people.last_name = ?",
            duplicate_contact.first_name, duplicate_contact.last_name
          )

          # Prioritize person record that has user record
          original_record = records.where("people.user_id IS NOT NULL").first

          # If there's no original record found above, find the oldest person record
          unless original_record.present?
            original_record = records.first
          end

          # Merging duplicates
          records.where("people.id <> ?", original_record.id).each do |record|
            original_record.merge(record)
            puts "Merging #{original_record.name} records..."
          end
        end
      else
        puts "There's no duplicate contacts in #{org.name}"
      end
    else
      puts "Can't find the organization"
    end
  end

  def down
  end
end
