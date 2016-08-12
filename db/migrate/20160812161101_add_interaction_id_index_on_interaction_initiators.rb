class AddInteractionIdIndexOnInteractionInitiators < ActiveRecord::Migration
  def change
    add_index :interaction_initiators, :interaction_id
  end
end
