class AddIndexToContactAssignment < ActiveRecord::Migration
  def change
    add_index :contact_assignments, [:assigned_to_id, :organization_id]
    add_index :contact_assignments, :organization_id
    add_index :organizational_roles, [:organization_id, :role_id, :followup_status], :name => "role_org_status"
    add_index :mh_answer_sheets, :question_sheet_id
  end
end