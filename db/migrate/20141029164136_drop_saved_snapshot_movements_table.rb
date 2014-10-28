class DropSavedSnapshotMovementsTable < ActiveRecord::Migration
  def up
    drop_table :saved_snapshot_movements
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
