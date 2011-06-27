class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.belongs_to :target_area
      t.belongs_to :organization
      t.date :start_date
      t.date :end_date
      t.string :status, default: 'active'

      t.timestamps
    end
    add_index :activities, [:target_area_id, :organization_id], unique: true
  end
end
