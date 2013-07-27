class CreateInteractionTypes < ActiveRecord::Migration
  def change
    create_table :interaction_types do |t|
      t.integer :organization_id
      t.string :name
      t.string :i18n
      t.string :icon

      t.timestamps
    end
  end
end
