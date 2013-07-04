class CreateMovementIndicatorSuggestions < ActiveRecord::Migration
  def change
    create_table :movement_indicator_suggestions do |t|
      t.belongs_to :person
      t.belongs_to :organization
      t.belongs_to :label
      t.boolean :accepted
      t.string :reason, limit: 1000
      t.string :action, null: false

      t.timestamps
    end
    add_index :movement_indicator_suggestions, [:organization_id, :person_id], name: 'person_organization'
    add_index :movement_indicator_suggestions, [:organization_id, :person_id, :label_id, :action], name: 'person_organization_label'
  end
end
