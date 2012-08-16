class AddOrgIdsIndexToPerson < ActiveRecord::Migration
  def change
    add_index :ministry_person, :org_ids_cache, length: 4000
  end
end
