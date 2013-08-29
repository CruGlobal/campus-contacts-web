class AddSomeMoreIndexes < ActiveRecord::Migration
  def change
    add_index :groups, :name
    add_index :groups, :organization_id
    add_index :interaction_types, :organization_id
    add_index :interactions, :interaction_type_id
    add_index :interactions, :receiver_id
    add_index :interactions, :organization_id
    add_index :labels, :organization_id
    add_index :labels, :name
    add_index :organizational_labels, :person_id
    add_index :organizational_labels, :label_id
    add_index :organizational_labels, :organization_id
    add_index :organizational_permissions, :person_id
    add_index :organizational_permissions, :permission_id
    add_index :organizational_permissions, :organization_id
    add_index :permissions, :name
  end
end
