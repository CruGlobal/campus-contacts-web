class AddPersonIdIndexToInteractionInitiators < ActiveRecord::Migration
  def change
    add_index :interaction_initiators, :person_id
  end
end
