class RemoveCacheColumnsFromPerson < ActiveRecord::Migration
  def change
    remove_column :people, :org_ids_cache
    remove_column :people, :organization_tree_cache
  end
end
