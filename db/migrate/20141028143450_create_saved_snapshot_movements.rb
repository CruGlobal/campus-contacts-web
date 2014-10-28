class CreateSavedSnapshotMovements < ActiveRecord::Migration
  def change
    create_table :saved_snapshot_movements do |t|
      t.references :person
      t.references :organization
      t.string :name
      t.text :movement_ids

      t.timestamps
    end
    add_index :saved_snapshot_movements, :person_id
    add_index :saved_snapshot_movements, :organization_id
  end
end
