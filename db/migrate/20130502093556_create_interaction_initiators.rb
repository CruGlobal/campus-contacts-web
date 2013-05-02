class CreateInteractionInitiators < ActiveRecord::Migration
  def change
    create_table :interaction_initiators do |t|
      t.integer :person_id
      t.integer :interaction_id

      t.timestamps
    end
  end
end
