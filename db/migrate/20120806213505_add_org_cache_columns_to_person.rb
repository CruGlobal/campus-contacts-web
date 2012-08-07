class AddOrgCacheColumnsToPerson < ActiveRecord::Migration
  def change
    add_column :ministry_person, :organization_tree_cache, :text
    add_column :ministry_person, :org_ids_cache, :text
  end
end
