class AddPublicFieldsToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :list_publicly, :boolean, :default => true
    add_column :groups, :approve_join_requests, :boolean, :default => true
  end
end
