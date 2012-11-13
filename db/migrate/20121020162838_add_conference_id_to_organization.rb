class AddConferenceIdToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :conference_id, :integer
    add_index :organizations, :conference_id
    
    change_table :people, bulk: true do |t|
      t.integer :crs_profile_id
      t.integer :sp_person_id
      t.integer :si_person_id
      t.integer :pr_person_id
    end
    add_index :people, :crs_profile_id
    add_index :people, :sp_person_id
    add_index :people, :si_person_id
    add_index :people, :pr_person_id
    
    # Create mappings for everyone before the split
    Person.where("created_at <= '2012-10-16'").update_all("sp_person_id = id, si_person_id = id, pr_person_id = id")
    Ccc::Crs2Profile.where("created_at <= '2012-10-16' AND ministry_person_id is not null").find_each do |profile|
      Person.where(id: profile.ministry_person_id).update_all(crs_profile_id: profile.id)
    end
  end
end