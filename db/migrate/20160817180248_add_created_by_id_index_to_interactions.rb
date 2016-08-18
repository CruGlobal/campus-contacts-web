class AddCreatedByIdIndexToInteractions < ActiveRecord::Migration
  def change
    add_index :interactions, :created_by_id
  end
end
