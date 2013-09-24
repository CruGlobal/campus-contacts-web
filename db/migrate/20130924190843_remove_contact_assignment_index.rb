class RemoveContactAssignmentIndex < ActiveRecord::Migration
  def up
    # remove_index(:contact_assignments, :name => 'index_contact_assignments_on_organization_id')
    remove_index(:contact_assignments, :name => 'index_contact_assignments_on_person_id_and_organization_id')
  end

  def down
    add_index :contact_assignments, :organization_id
  end
end
