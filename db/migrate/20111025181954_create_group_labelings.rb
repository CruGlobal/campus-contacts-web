class CreateGroupLabelings < ActiveRecord::Migration
  def change
    create_table :mh_group_labelings do |t|
      t.belongs_to :group
      t.belongs_to :group_label

      t.timestamps
    end
    add_index :mh_group_labelings, [:group_id, :group_label_id], :unique => true
    add_index :mh_group_labelings, :group_label_id
  end
end
