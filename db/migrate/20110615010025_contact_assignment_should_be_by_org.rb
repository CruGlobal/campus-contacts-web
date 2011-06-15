class ContactAssignment < ActiveRecord::Base
  belongs_to :question_sheet
  belongs_to :organization
end

class ContactAssignmentShouldBeByOrg < ActiveRecord::Migration
  def up
    add_column :contact_assignments, :organization_id, :integer
    ContactAssignment.all.each do |ca|
      ca.update_attribute(:organization_id, ca.question_sheet.questionnable.organization_id)
    end
    remove_column :contact_assignments, :question_sheet_id
  end

  def down
    add_column :contact_assignments, :question_sheet_id, :integer
    ContactAssignment.all.each do |ca|
      ca.update_attribute(:question_sheet_id, ca.organization.question_sheets.first.try(:id))
    end
    remove_column :contact_assignments, :organization_id
  end
end