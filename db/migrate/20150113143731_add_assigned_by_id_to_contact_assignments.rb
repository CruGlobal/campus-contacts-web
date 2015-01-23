class AddAssignedByIdToContactAssignments < ActiveRecord::Migration
  def change
    add_column :contact_assignments, :assigned_by_id, :integer, after: "person_id"
  end
end
