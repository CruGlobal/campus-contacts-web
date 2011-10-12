class CreateGroupLabels < ActiveRecord::Migration
  def change
    create_table :mh_group_labels do |t|
      t.string :name
      t.belongs_to :organization
      t.string :ancestry

      t.timestamps
    end
    add_index :mh_group_labels, :organization_id
  end
end
