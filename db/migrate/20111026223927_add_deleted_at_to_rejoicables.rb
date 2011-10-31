class AddDeletedAtToRejoicables < ActiveRecord::Migration
  def change
    add_column :rejoicables, :deleted_at, :datetime
  end
end
