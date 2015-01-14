class MergeDuplicateSurveysInOrganization3523 < ActiveRecord::Migration
  def up
    # Reported in Jira MH-1058
    # Duplicates were created because of bug in transfer contacts with survey answers in all contacts page.
    org_id = 3523
    org = Organization.find_by_id(org_id)
    puts "Start Migration: Merge Duplicate Surveys in Organization id: #{org_id}"
    if org.present?
      puts "Checking if there's a duplicate"
      duplicates = org.find_duplicate_surveys_by_title
      if duplicates.present?
        puts "Merging duplicates..."
        org.merge_duplicate_surveys_by_title(duplicates.collect(&:title))
        puts "Done merging duplicates..."
      else
        puts "Cannot find any duplicate surveys in organization id(#{org_id})"
      end
    else
      puts "Cannot find the organization id(#{org_id}) in the database"
    end
  end

  def down
  end
end
