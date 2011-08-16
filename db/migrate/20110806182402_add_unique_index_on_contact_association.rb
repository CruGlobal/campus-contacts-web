class AddUniqueIndexOnContactAssociation < ActiveRecord::Migration
  def up
    add_index :contact_assignments, [:person_id, :organization_id], :unique => true
  end

  def down
    remove_index :contact_assignments, [:person_id, :organization_id]
  end
end