class AddConferenceIdToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :conference_id, :integer
    add_index :organizations, :conference_id

    add_index :people, :crs_profile_id
    add_index :people, :sp_person_id
    add_index :people, :si_person_id
    add_index :people, :pr_person_id
  end
end