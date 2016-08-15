class AddIndexsOnInteractions < ActiveRecord::Migration
  def change
    add_index :interactions, [:interaction_type_id, :organization_id, :deleted_at],
              name: 'index_interactions_ids'
    remove_index :interactions, column: :interaction_type_id
  end
end
