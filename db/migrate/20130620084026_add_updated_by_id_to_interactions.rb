class AddUpdatedByIdToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :updated_by_id, :integer, after: 'created_by_id'
  end
end
