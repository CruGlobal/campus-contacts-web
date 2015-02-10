class MergeDuplicateSurveysInOrganization169 < ActiveRecord::Migration
  def up
    # Reported in Jira MH-1098
    # Duplicates were created because of bug(before Jan 15, 2015) in transfer contacts with survey answers in all contacts page.


    # to_org_id is the organization where they transfer the contacts
    to_org_id = 169
    to_org = Organization.find_by_id(to_org_id)

    # from_org_id is the organization where they get the contacts
    from_org_id = 10341
    from_org = Organization.find_by_id(from_org_id)

    puts "Start Migration: Merge Duplicate Surveys in Organization id: #{to_org_id}"
    if to_org.present?
      puts "Checking if there's a duplicate"
      duplicates = to_org.find_duplicate_surveys_by_title
      if duplicates.present?
        puts "Merging duplicates..."
        to_org.merge_duplicate_surveys_by_title(duplicates.collect(&:title), from_org)
        puts "Done merging duplicates..."
      else
        puts "Cannot find any duplicate surveys in organization id(#{to_org_id})"
      end
    else
      puts "Cannot find the organization id(#{to_org_id}) in the database"
    end
  end

  def down
  end
end
