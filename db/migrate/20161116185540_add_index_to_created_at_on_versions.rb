class AddIndexToCreatedAtOnVersions < ActiveRecord::Migration
  def up
    execute 'create index index_versions_on_created_at on versions (`created_at`) lock=none;'
  end

  def down
    remove_index :versions, fields: [:created_at], name: 'index_versions_on_created_at'
  end
end
