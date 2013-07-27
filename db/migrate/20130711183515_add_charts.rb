class AddCharts < ActiveRecord::Migration
  def change
    create_table :charts do |t|
      t.integer :person_id
      t.string :chart_type
      t.boolean :snapshot_all_movements, :default => true
      t.integer :snapshot_evang_range, :default => 6
      t.integer :snapshot_laborers_range, :default => 0

      t.timestamps
    end
    
    add_index :charts, :person_id
    add_index :charts, :chart_type
    add_index :charts, [:person_id, :chart_type], unique: true
    
    create_table :chart_organizations do |t|
      t.integer :chart_id
      t.integer :organization_id
      t.boolean :snapshot_display, :default => true
      
      t.timestamps
    end
    
    add_index :chart_organizations, :chart_id
    add_index :chart_organizations, :organization_id
    add_index :chart_organizations, [:chart_id, :organization_id], unique: true
  end
end
