class AddIndexToVersions < ActiveRecord::Migration
  def up
    execute 'create index index_versions_on_item_id on versions (`item_id`) lock=none;'
  end

  def down
    remove_index :versions, fields: [:item_id], name: 'index_versions_on_item_id'
  end
end
