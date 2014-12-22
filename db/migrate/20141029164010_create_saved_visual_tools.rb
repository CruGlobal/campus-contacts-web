class CreateSavedVisualTools < ActiveRecord::Migration
  def change
    create_table :saved_visual_tools do |t|
      t.references :person
      t.references :organization
      t.string :group
      t.string :name
      t.text :movement_ids

      t.timestamps
    end
    add_index :saved_visual_tools, :person_id
    add_index :saved_visual_tools, :organization_id
  end
end
