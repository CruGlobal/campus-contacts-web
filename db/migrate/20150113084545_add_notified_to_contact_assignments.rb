class AddNotifiedToContactAssignments < ActiveRecord::Migration
  def change
    add_column :contact_assignments, :notified, :boolean, after: "person_id", default: false
    ContactAssignment.update_all(notified: true)
  end
end
