class AddPersonIdIndexToContactAssignment < ActiveRecord::Migration
  def change
    add_index :contact_assignments, :person_id
  end
end
