class AddGoalTrackerColumns < ActiveRecord::Migration
  def change
    add_column :charts, :goal_organization_id, :integer
    add_column :charts, :goal_criteria, :string

    create_table :organizational_goals do |t|
      t.integer :organization_id
      t.string :criteria
      t.integer :start_value
      t.integer :end_value
      t.date :start_date
      t.date :end_date
      t.timestamps
    end

    add_index :organizational_goals, :organization_id
    add_index :organizational_goals, :criteria
  end
end
