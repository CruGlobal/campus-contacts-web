class AddOrganizationIdToClient < ActiveRecord::Migration
  def change
    add_column :clients, :organization_id, :integer
    add_index :clients, :organization_id
  end
end