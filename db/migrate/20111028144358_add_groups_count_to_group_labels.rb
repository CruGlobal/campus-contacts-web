class AddGroupsCountToGroupLabels < ActiveRecord::Migration
  def change
    add_column :mh_group_labels, :group_labelings_count, :integer, :default => 0
    rename_table :group_memberships, :mh_group_memberships
  end
end