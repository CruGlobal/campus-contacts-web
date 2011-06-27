class CreateMergeAudits < ActiveRecord::Migration
  def change
    create_table :merge_audits do |t|
      t.integer :mergeable_id
      t.string :mergeable_type
      t.integer :merge_looser_id
      t.string :merge_looser_type

      t.timestamps
    end
    add_index :merge_audits, [:mergeable_id, :mergeable_type], name: "mergeable"
    add_index :merge_audits, [:merge_looser_id, :merge_looser_type], name: "merge_looser"
  end
end